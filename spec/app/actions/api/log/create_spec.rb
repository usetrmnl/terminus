# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::API::Log::Create, :db do
  subject(:action) { described_class.new logger: }

  let(:device) { Factory[:device] }
  let(:logger) { instance_spy Dry::Logger::Dispatcher }

  describe "#call" do
    let :headers do
      {
        "CONTENT_TYPE" => "application/json",
        "HTTP_ID" => device.mac_address,
        "HTTP_ACCESS_TOKEN" => device.api_key
      }
    end

    it "logs errors when parameters are invalid" do
      action.call Rack::MockRequest.env_for("", headers)
      expect(logger).to have_received(:error).with(logs: ["is missing"])
    end
  end
end
