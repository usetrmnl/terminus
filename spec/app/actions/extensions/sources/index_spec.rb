# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Sources::Index, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange, data: {"source_1" => 1}] }

    it "renders default response" do
      response = action.call Rack::MockRequest.env_for(
        exchange.extension_id.to_s,
        "router.params" => {extension_id: exchange.extension_id}
      )

      expect(response.body.first).to start_with("<!DOCTYPE html>")
    end

    it "renders htmx response" do
      response = action.call Rack::MockRequest.env_for(
        exchange.extension_id.to_s,
        "HTTP_HX_REQUEST" => "true",
        "router.params" => {extension_id: exchange.extension_id}
      )

      expect(response.body.first).to start_with("<textarea")
    end

    it "renders sources" do
      response = action.call Rack::MockRequest.env_for(
        exchange.extension_id.to_s,
        "router.params" => {extension_id: exchange.extension_id}
      )

      expect(response.body.first).to include("source_1")
    end
  end
end
