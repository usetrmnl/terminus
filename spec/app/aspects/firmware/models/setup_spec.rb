# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Firmware::Models::Setup, :db do
  subject(:model) { described_class.new }

  describe ".for" do
    it "answers welcome record" do
      device = Factory[:device, api_key: "abc123"]

      expect(described_class.for(device)).to eq(
        described_class[
          api_key: "abc123",
          image_url: %(#{Hanami.app[:settings].api_uri}/assets/setup.bmp),
          message: "Welcome to Terminus!",
          status: 200
        ]
      )
    end
  end

  describe ".welcome" do
    it "answers welcome record" do
      randomizer = class_double SecureRandom, alphanumeric: "abc123"

      expect(described_class.welcome(randomizer:)).to eq(
        described_class[
          api_key: "abc123",
          image_url: %(#{Hanami.app[:settings].api_uri}/assets/setup.bmp),
          message: "Welcome to Terminus!",
          status: 200
        ]
      )
    end
  end

  describe "#initialize" do
    it "answers default attributes" do
      expect(model.to_h).to eq(
        api_key: nil,
        image_url: nil,
        message: "Device not registered.",
        status: 404
      )
    end

    it "is frozen" do
      expect(model.frozen?).to be(true)
    end
  end

  describe "#to_json" do
    it "answers JSON" do
      payload = JSON model.to_json, symbolize_names: true

      expect(payload).to eq(
        api_key: nil,
        image_url: nil,
        message: "Device not registered.",
        status: 404
      )
    end
  end
end
