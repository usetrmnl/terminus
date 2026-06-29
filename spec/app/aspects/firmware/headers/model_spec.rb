# frozen_string_literal: true

require "hanami_helper"
require "versionaire"

RSpec.describe Terminus::Aspects::Firmware::Headers::Model do
  using Refinements::Hash
  using Versionaire::Cast

  subject :record do
    described_class[
      battery_charge: 85.0,
      battery_voltage: 4.74,
      charging: false,
      firmware_profile: true,
      firmware_version: Version("1.2.3"),
      height: 480,
      host: "https://localhost",
      image_cached: false,
      mac_address: "A1:B2:C3:D4:E5:F6",
      model_name: "og",
      refresh_rate: 25,
      sensors: [],
      user_agent: "ESP32HTTPClient",
      wake_duration: 20,
      wake_reason: "Button pressed.",
      width: 800,
      wifi_band: 2.4,
      wifi_signal: -40
    ]
  end

  include_context "with firmware headers"

  describe ".for" do
    it "answers record for raw HTTP headers" do
      record = described_class.for firmware_headers.symbolize_keys!

      expect(record).to eq(
        described_class[
          api_key: "",
          battery_charge: "85",
          battery_voltage: "4.74",
          charging: "false",
          firmware_version: "1.2.3",
          height: "480",
          host: "https://localhost",
          image_cached: "false",
          mac_address: "A1:B2:C3:D4:E5:F6",
          model_name: "og",
          refresh_rate: "25",
          sensors: "make=Sensirion;model=SCD41;kind=humidity;value=26;" \
                   "unit=percent;created_at=1735714800",
          firmware_profile: "true",
          user_agent: "ESP32HTTPClient",
          wake_duration: "20",
          wake_reason: "Button pressed.",
          width: "800",
          wifi_band: "2.4",
          wifi_signal: "-54"
        ]
      )
    end
  end

  describe "#initialize" do
    it "is frozen" do
      expect(described_class.new.frozen?).to be(true)
    end
  end

  describe "#computed_mac_address" do
    it "answers MAC address when present" do
      expect(record.computed_mac_address).to eq("A1:B2:C3:D4:E5:F6")
    end

    it "answers MAC address when MAC address isn't present but API Key is" do
      record = described_class[api_key: "A1:B2:C3:D4:E5:F6"]
      expect(record.computed_mac_address).to eq("A1:B2:C3:D4:E5:F6")
    end

    it "answers nil when MAC address and API Key aren't present" do
      expect(described_class.new.computed_mac_address).to be(nil)
    end
  end

  describe "#device_attributes" do
    it "answers device attributes" do
      expect(record.device_attributes).to eq(
        battery_charge: 85.0,
        battery_voltage: 4.74,
        charging: false,
        firmware_profile: true,
        firmware_version: "1.2.3",
        height: 480,
        image_cached: false,
        wake_duration: 20,
        wake_reason: "Button pressed.",
        width: 800,
        wifi_band: 2.4,
        wifi_signal: -40
      )
    end

    it "answers empty hash when attributes don't exist" do
      record = described_class.new
      expect(record.device_attributes).to eq({})
    end
  end
end
