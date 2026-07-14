# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::Defaulter do
  subject(:builder) { described_class.new }

  describe "#call" do
    it "answers random defaults" do
      expect(builder.call).to match(
        api_key: match_device_api_key,
        mac_address: match_mac_address,
        firmware_update: true,
        image_timeout: 0,
        label: "TRMNL",
        refresh_rate: 900
      )
    end

    it "answers exact defaults" do
      randomizer = class_double SecureRandom, hex: "abc123", alphanumeric: "abc123"
      mac_address_builder = instance_double Proc, call: "02:A1:B2:C3:D4:E5"
      builder = described_class.new(randomizer:, mac_address_builder:)

      expect(builder.call).to eq(
        api_key: "abc123",
        mac_address: "02:A1:B2:C3:D4:E5",
        firmware_update: true,
        image_timeout: 0,
        label: "TRMNL",
        refresh_rate: 900
      )
    end
  end
end
