# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Exchanges::Edit, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    it "answers 200 OK status with valid parameters" do
      response = action.call extension_id: exchange.extension_id, id: exchange.id
      expect(response.status).to eq(200)
    end

    it "renders htmx response" do
      response = action.call Rack::MockRequest.env_for(
        exchange.id.to_s,
        "HTTP_HX_REQUEST" => "true",
        "router.params" => {extension_id: exchange.extension_id, id: exchange.id}
      )

      expect(response.body.first).to have_htmx_title("Edit Exchange")
    end

    it "answers error with invalid parameters" do
      response = action.call Hash.new
      expect(response.status).to eq(422)
    end
  end
end
