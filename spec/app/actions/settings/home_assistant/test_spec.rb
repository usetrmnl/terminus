# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Settings::HomeAssistant::Test, :db do
  subject(:action) { described_class.new connection_tester: }

  let(:connection_tester) { instance_double Terminus::Aspects::HomeAssistant::ConnectionTester, call: Success({"message" => "API running."}) }

  it "sets success flash" do
    Factory[:home_assistant_connection]
    response = action.call Rack::MockRequest.env_for(
      "/settings/home-assistant/test",
      method: "POST"
    )

    expect(response).to have_attributes(
      status: 302,
      headers: include("Location" => "/settings/home-assistant")
    )
  end
end
