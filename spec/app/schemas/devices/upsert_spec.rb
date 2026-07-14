# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Schemas::Devices::Upsert do
  subject(:contract) { described_class }

  describe "#call" do
    let :attributes do
      {
        model_id: 1,
        playlist_id: nil,
        label: "Test",
        mac_address: "AA:BB:CC:11:22:33",
        api_key: "secret",
        refresh_rate: 100,
        image_cached: "on",
        image_timeout: 0,
        display_compatibility: "on",
        display_profile: "default",
        firmware_profile: "on",
        firmware_update: "on",
        firmware_version: "1.2.3",
        charging: "on",
        battery_charge: 85.0,
        battery_voltage: 3.5,
        wifi_band: 2.4,
        wifi_signal: -75,
        width: 800,
        height: 480,
        touch_bar: "tap",
        wake_duration: 123,
        wake_reason: "Awoken from test.",
        sleep_start_at: "18:00:00",
        sleep_stop_at: "06:00:00",
        synced_at: "2026-06-01T01:02:03+00:00"
      }
    end

    it "answers success when all attributes are valid" do
      expect(contract.call(attributes).to_monad).to be_success
    end

    it "answers failure when battery charge is less than zero" do
      attributes[:battery_charge] = -1

      expect(contract.call(attributes).errors.to_h).to include(
        battery_charge: ["must be greater than or equal to 0"]
      )
    end

    it "answers failure when wifi band is less than zero" do
      attributes[:wifi_band] = -1

      expect(contract.call(attributes).errors.to_h).to include(
        wifi_band: ["must be greater than or equal to 0"]
      )
    end

    it "answers failure when refresh rate is less than zero" do
      attributes[:refresh_rate] = -1

      expect(contract.call(attributes).errors.to_h).to include(
        refresh_rate: ["must be greater than 0"]
      )
    end

    it "answers failure when image timeout is less than zero" do
      attributes[:image_timeout] = -1

      expect(contract.call(attributes).errors.to_h).to include(
        image_timeout: ["must be greater than or equal to 0"]
      )
    end

    it "answers true when image cached is truthy" do
      expect(contract.call(attributes).to_h).to include(image_cached: true)
    end

    it "answers false when image cached key is missing" do
      attributes.delete :image_cached
      expect(contract.call(attributes).to_h).to include(image_cached: false)
    end

    it "answers true when display compatibility is truthy" do
      expect(contract.call(attributes).to_h).to include(display_compatibility: true)
    end

    it "answers false when display compatibility key is missing" do
      attributes.delete :display_compatibility
      expect(contract.call(attributes).to_h).to include(display_compatibility: false)
    end

    it "answers true when firmware profile is truthy" do
      expect(contract.call(attributes).to_h).to include(firmware_profile: true)
    end

    it "answers false when firmware_profile key is missing" do
      attributes.delete :firmware_profile
      expect(contract.call(attributes).to_h).to include(firmware_profile: false)
    end

    it "answers true when firmware update is truthy" do
      expect(contract.call(attributes).to_h).to include(firmware_update: true)
    end

    it "answers false when firmware update key is missing" do
      attributes.delete :firmware_update
      expect(contract.call(attributes).to_h).to include(firmware_update: false)
    end

    it "answers true when charging is truthy" do
      expect(contract.call(attributes).to_h).to include(charging: true)
    end

    it "answers false when charging key is missing" do
      attributes.delete :charging
      expect(contract.call(attributes).to_h).to include(charging: false)
    end
  end
end
