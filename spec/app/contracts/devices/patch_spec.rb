# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Devices::Patch do
  subject(:contract) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        id: 1,
        device: {
          model_id: 1,
          playlist_id: 1,
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
      }
    end

    it_behaves_like "a sleep contract"
  end
end
