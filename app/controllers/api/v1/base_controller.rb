# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  private

  def current_workspace
    @current_workspace ||= current_user&.workspace
  end

  def render_success(data: nil, message: nil, status: :ok, meta: nil)
    response = { status: { code: Rack::Utils.status_code(status), message: message } }
    response[:data] = data if data
    response[:meta] = meta if meta
    render json: response, status: status
  end

  def render_error(message:, status: :unprocessable_entity, errors: nil)
    response = { 
      status: { 
        code: Rack::Utils.status_code(status), 
        message: message 
      } 
    }
    response[:errors] = errors if errors
    render json: response, status: status
  end
end
