# frozen_string_literal: true

require "hanami_helper"
require "versionaire"

RSpec.describe Terminus::Models::Firmware::Header do
  using Refinements::Hash
  using Versionaire::Cast

  subject :record do
    described_class[
      api_key: "abc123",
      battery: 4.74,
      firmware_version: Version("1.2.3"),
      height: 480,
      host: "https://localhost",
      mac_address: "A1:B2:C3:D4:E5:F6",
      model_name: "og",
      refresh_rate: 25,
      sensors: [],
      user_agent: "ESP32HTTPClient",
      width: 800,
      wifi: -40
    ]
  end

  include_context "with firmware headers"

  describe ".for" do
    it "answers record for raw HTTP headers" do
      record = described_class.for firmware_headers.symbolize_keys!

      expect(record).to eq(
        described_class[
          api_key: "abc123",
          battery: "4.74",
          firmware_version: "1.2.3",
          height: "480",
          host: "https://localhost",
          mac_address: "A1:B2:C3:D4:E5:F6",
          model_name: "og",
          refresh_rate: "25",
          sensors: "make=Sensirion;model=SCD41;kind=humidity;value=26;" \
                   "unit=percent;created_at=1735714800",
          user_agent: "ESP32HTTPClient",
          width: "800",
          wifi: "-54"
        ]
      )
    end
  end

  describe "#initialize" do
    it "is frozen" do
      expect(described_class.new.frozen?).to be(true)
    end
  end

  describe "#device_attributes" do
    it "answers device attributes" do
      expect(record.device_attributes).to eq(
        battery: 4.74,
        firmware_version: "1.2.3",
        wifi: -40,
        width: 800,
        height: 480
      )
    end

    it "answers empty hash when attributes don't exist" do
      record = described_class.new
      expect(record.device_attributes).to eq({})
    end
  end
end
