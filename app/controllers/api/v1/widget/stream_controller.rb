# frozen_string_literal: true

# SSE (Server-Sent Events) controller for real-time widget updates
# No Redis required - uses PostgreSQL LISTEN/NOTIFY
class Api::V1::Widget::StreamController < ApplicationController
  include ActionController::Live

  skip_before_action :verify_authenticity_token, raise: false

  # GET /api/v1/widget/stream?session_token=xxx
  def show
    session_token = params[:session_token]
    
    # Validate widget session
    widget_session = WidgetSession.find_by_token(session_token)
    unless widget_session
      render json: { error: 'Invalid session' }, status: :unauthorized
      return
    end

    # Set SSE headers
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Connection'] = 'keep-alive'
    response.headers['X-Accel-Buffering'] = 'no'  # Disable nginx buffering

    # Mark session as connected
    widget_session.connect!

    # Get the ticket IDs this session should receive updates for
    customer = widget_session.customer
    ticket_ids = customer ? customer.tickets.pluck(:id) : []

    # Channel for this session
    channel = "widget_updates_#{widget_session.id}"

    sse = SSE.new(response.stream, event: 'message')

    begin
      # Send initial connection confirmation
      sse.write({ type: 'connected', session_id: widget_session.id })

      # Listen for updates using PostgreSQL LISTEN/NOTIFY
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        raw_conn = conn.raw_connection
        raw_conn.exec("LISTEN #{channel}")

        loop do
          # Wait for notification with 30s timeout (heartbeat)
          raw_conn.wait_for_notify(30) do |ch, pid, payload|
            data = JSON.parse(payload) rescue { type: 'ping' }
            sse.write(data)
          end

          # Send heartbeat if no notification
          sse.write({ type: 'ping', timestamp: Time.current.to_i })

          # Refresh session
          widget_session.heartbeat!
        end
      end
    rescue ActionController::Live::ClientDisconnected, IOError
      # Client disconnected
      Rails.logger.info "[SSE] Client disconnected: #{widget_session.id}"
    ensure
      widget_session.disconnect!
      sse.close rescue nil
    end
  end
end

# SSE helper class
class SSE
  def initialize(stream, options = {})
    @stream = stream
    @event = options[:event]
  end

  def write(data, options = {})
    event = options[:event] || @event
    output = ""
    output << "event: #{event}\n" if event
    output << "data: #{data.to_json}\n\n"
    @stream.write(output)
  end

  def close
    @stream.close
  end
end
