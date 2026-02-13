# frozen_string_literal: true

# Widget API controller for embedded support widget
# Handles session creation, ticket creation, and messaging
class Api::V1::Widget::WidgetController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  before_action :authenticate_widget_request
  before_action :set_widget_session, except: [:init]

  # POST /api/v1/widget/init
  # Initialize a widget session for a visitor
  def init
    # Validate workspace
    # @workspace = Workspace.find_by(widget_api_key: params[:api_key])
    
    # [NEW] Authenticate via WidgetKey
    widget_key = WidgetKey.find_by(public_key: params[:api_key])
    if widget_key&.active?
      @workspace = widget_key.workspace
      widget_key.used!
    else
      return render json: { error: 'Invalid or revoked API key' }, status: :unauthorized
    end

    # Check domain if restricted
    origin = request.headers['Origin'] || request.headers['Referer']
    origin_host = (URI.parse(origin).host rescue nil)
    if origin && !widget_key.domain_allowed?(origin_host)
      return render json: { error: 'Domain not allowed' }, status: :forbidden
    end

    # Find or create customer
    customer = find_or_create_customer

    # Create widget session
    session = WidgetSession.create_for_visitor(
      workspace: @workspace,
      fingerprint: params[:fingerprint],
      customer: customer,
      metadata: {
        page_url: params[:page_url],
        referrer: params[:referrer],
        user_agent: request.user_agent
      }
    )

    # Get existing tickets for this customer
    tickets = customer&.tickets&.open_tickets&.recent&.limit(5) || []

    render json: {
      session_token: session.session_token,
      customer_id: customer&.id,
      workspace: {
        name: @workspace.name,
        settings: @workspace.widget_settings
      },
      tickets: tickets.map { |t| ticket_summary(t) }
    }
  end

  # POST /api/v1/widget/tickets
  # Create a new ticket from the widget
  def create_ticket
    customer = ensure_customer_exists

    ActiveRecord::Base.transaction do
      # Create ticket
      ticket = @workspace.tickets.create!(
        customer: customer,
        subject: params[:subject] || params[:message].truncate(100),
        description: params[:message],
        source: :widget,
        category: params[:category] || 'general',
        subcategory: params[:subcategory] || 'inquiry',
        widget_session: @widget_session,
        source_url: params[:page_url]
      )

      # Create first message
      message = ticket.messages.create!(
        customer: customer,
        body: params[:message],
        message_type: 'customer'
      )

      # Create outbox event for Discord notification
      OutboxEvent.publish!(
        event_type: OutboxEvent::TICKET_CREATED,
        aggregate: ticket,
        payload: {
          ticket_number: ticket.ticket_number,
          customer_email: customer.email,
          customer_name: customer.display_name,
          message: params[:message],
          workspace_id: @workspace.id,
          page_url: params[:page_url]
        }
      )

      render json: {
        ticket: ticket_summary(ticket),
        message: message_summary(message)
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /api/v1/widget/tickets/:id
  # Get ticket details and messages
  def show_ticket
    ticket = find_customer_ticket(params[:id])
    return render json: { error: 'Ticket not found' }, status: :not_found unless ticket

    messages = ticket.messages.order(created_at: :asc).limit(100)

    render json: {
      ticket: ticket_summary(ticket),
      messages: messages.map { |m| message_summary(m) }
    }
  end

  # POST /api/v1/widget/tickets/:id/messages
  # Send a message in an existing ticket
  def create_message
    ticket = find_customer_ticket(params[:id])
    return render json: { error: 'Ticket not found' }, status: :not_found unless ticket

    ActiveRecord::Base.transaction do
      message = ticket.messages.create!(
        customer: @widget_session.customer,
        body: params[:message],
        message_type: 'customer'
      )

      # Create outbox event for Discord
      OutboxEvent.publish!(
        event_type: OutboxEvent::MESSAGE_FROM_CUSTOMER,
        aggregate: message,
        payload: {
          ticket_id: ticket.id,
          discord_thread_id: ticket.discord_thread_id,
          message: params[:message],
          customer_name: @widget_session.customer&.display_name || 'Customer'
        }
      )

      render json: { message: message_summary(message) }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /api/v1/widget/identify
  # Upgrade anonymous customer to identified (with email)
  def identify
    if params[:email].blank?
      return render json: { error: 'Email required' }, status: :unprocessable_entity
    end

    customer = @widget_session.customer

    if customer&.identified?
      # Already identified - update name if provided
      customer.update!(name: params[:name]) if params[:name].present?
    else
      # Find or create customer by email
      customer = Customer.find_or_create_by_email(
        workspace: @workspace,
        email: params[:email],
        attrs: {
          name: params[:name],
          fingerprint: @widget_session.fingerprint
        }
      )

      # Update session with customer
      @widget_session.associate_customer!(customer)
    end

    render json: {
      customer_id: customer.id,
      identified: true
    }
  end

  private

  def authenticate_widget_request
    # @workspace = Workspace.find_by(widget_api_key: params[:api_key])
    
    widget_key = WidgetKey.find_by(public_key: params[:api_key])
    if widget_key&.active?
      @workspace = widget_key.workspace
      # Optional: log usage on every request? Maybe too heavy. 
      # Init is the main entry point, so logging there is sufficient for now.
    else
      render json: { error: 'Invalid API key' }, status: :unauthorized
    end
  end

  def set_widget_session
    @widget_session = WidgetSession.find_by_token(params[:session_token])
    unless @widget_session
      render json: { error: 'Invalid session' }, status: :unauthorized
    end
  end

  def find_or_create_customer
    if params[:email].present?
      Customer.find_or_create_by_email(
        workspace: @workspace,
        email: params[:email],
        attrs: { name: params[:name], fingerprint: params[:fingerprint] }
      )
    elsif params[:fingerprint].present?
      Customer.find_or_create_by_fingerprint(
        workspace: @workspace,
        fingerprint: params[:fingerprint],
        attrs: { name: params[:name] }
      )
    end
  end

  def ensure_customer_exists
    customer = @widget_session.customer
    return customer if customer

    # Create customer from params
    customer = find_or_create_customer
    @widget_session.associate_customer!(customer) if customer
    customer
  end

  def find_customer_ticket(ticket_id)
    return nil unless @widget_session.customer

    @widget_session.customer.tickets.find_by(id: ticket_id)
  end

  def ticket_summary(ticket)
    {
      id: ticket.id,
      ticket_number: ticket.ticket_number,
      subject: ticket.subject,
      status: ticket.status,
      created_at: ticket.created_at.iso8601,
      last_message_at: ticket.messages.maximum(:created_at)&.iso8601
    }
  end

  def message_summary(message)
    {
      id: message.id,
      body: message.body,
      message_type: message.message_type,
      from: message.user_id ? 'agent' : 'customer',
      agent_name: message.user&.name,
      created_at: message.created_at.iso8601
    }
  end
end
