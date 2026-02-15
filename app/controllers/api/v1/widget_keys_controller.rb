# frozen_string_literal: true

class Api::V1::WidgetKeysController < Api::V1::BaseController
  before_action :set_widget_key, only: [:destroy]

  # GET /api/v1/widget_keys
  def index
    keys = current_workspace.widget_keys.order(created_at: :desc)
    
    data = WidgetKeySerializer.new(keys).serializable_hash[:data].map { |resource| resource[:attributes] }
    render_success(
      data: data,
      message: 'Widget keys retrieved successfully'
    )
  end

  # POST /api/v1/widget_keys
  def create
    key = current_workspace.widget_keys.new(widget_key_params)

    if key.save
      render_success(
        data: WidgetKeySerializer.new(key).serializable_hash[:data][:attributes],
        message: 'Widget key created successfully',
        status: :created
      )
    else
      render_error(message: key.errors.full_messages.to_sentence)
    end
  end

  # DELETE /api/v1/widget_keys/:id
  def destroy
    @widget_key.revoke!
    
    render_success(
      message: 'Widget key revoked successfully'
    )
  end

  private

  def set_widget_key
    @widget_key = current_workspace.widget_keys.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error(message: 'Widget key not found', status: :not_found)
  end

  def widget_key_params
    params.require(:widget_key).permit(:label, allowed_domains: [])
  end
end
