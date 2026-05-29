# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::HomeAssistant::ConnectionTester do
  subject(:tester) { described_class.new client: }

  let(:connection) { Factory.structs[:home_assistant_connection] }

  context "with success" do
    let(:client) { instance_double Terminus::Aspects::HomeAssistant::Client, call: Success({"message" => "API running."}) }

    it "answers success" do
      expect(tester.call(connection)).to be_success("message" => "API running.")
    end
  end

  context "with unauthorized failure" do
    let(:client) { instance_double Terminus::Aspects::HomeAssistant::Client, call: Failure("Home Assistant unauthorized (401).") }

    it "answers failure" do
      expect(tester.call(connection)).to be_failure("Home Assistant unauthorized (401).")
    end
  end
end
