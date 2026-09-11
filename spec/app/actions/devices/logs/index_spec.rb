# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Devices::Logs::Index, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:device_log) { Factory[:device_log] }

    it "answers unprocessable entity status when required parameters are missing" do
      response = action.call Rack::MockRequest.env_for("")
      expect(response.status).to eq(422)
    end

    it "renders default response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {device_id: device_log.device_id}
      )

      expect(response.body.first).to include("Danger!")
    end

    it "renders default response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {device_id: device_log.device_id, query: "bogus"}
      )

      expect(response.body.first).to include("No logs found.")
    end

    it "renders htmx response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {device_id: device_log.device_id}
      )

      expect(response.body.first).to include("Danger!")
    end

    it "renders htmx response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {device_id: device_log.device_id, query: "bogus"}
      )

      expect(response.body.first).to include("No logs found.")
    end
  end
end
