# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::HomeAssistant::Client do
  subject(:client) { described_class.new http: }

  let(:connection) { Factory.structs[:home_assistant_connection] }

  context "with successful request" do
    let :response do
      instance_double(
        HTTP::Response,
        status: instance_double(HTTP::Response::Status, success?: true),
        to_s: '{"message":"API running."}'
      )
    end
    let(:request_client) { instance_double HTTP::Client, get: response }
    let(:follow_client) { instance_double HTTP::Client, follow: request_client }
    let(:http) { instance_double HTTP::Client, headers: follow_client }

    it "sends bearer token authorization" do
      client.call connection, "/api/"
      expect(http).to have_received(:headers).with("Authorization" => "Bearer token123")
    end
  end
end
