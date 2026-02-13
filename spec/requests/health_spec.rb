require 'rails_helper'

RSpec.describe "Healths", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/health"
      expect(response).to have_http_status(:success)
    end
  end

end
