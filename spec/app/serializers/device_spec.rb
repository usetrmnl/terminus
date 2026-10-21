# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Serializers::Device, :db do
  subject(:serializer) { described_class.new device }

  let(:device) { Factory[:device, :with_playlist, **attributes] }

  let :attributes do
    {
      label: "Serialize Test",
      mac_address: "A1:B2:C3:D4:E5:F6",
      api_key: "abc123",
      firmware_profile: true,
      firmware_update: true,
      firmware_reset: true,
      firmware_version: "1.2.3",
      wake_reason: nil,
      wake_duration: 125,
      wifi_band: 0,
      wifi_signal: -40,
      battery_charge: 0.0,
      battery_voltage: 3.0,
      charging: false,
      refresh_rate: 500,
      image_cached: false,
      image_timeout: 5,
      display_compatibility: false,
      display_profile: "default",
      command: "none",
      touch_bar: "tap",
      sleep_start_at: "05:00:00",
      sleep_stop_at: "10:00:00"
    }
  end

  describe "#to_h" do
    it "answers hash" do
      expect(serializer.to_h).to match(
        id: device.id,
        model_id: device.model_id,
        playlist_id: device.playlist_id,
        label: "Serialize Test",
        mac_address: "A1:B2:C3:D4:E5:F6",
        api_key: "abc123",
        firmware_profile: true,
        firmware_update: true,
        firmware_reset: true,
        firmware_version: "1.2.3",
        wake_reason: nil,
        wake_duration: 125,
        wifi_band: 0.0,
        wifi_signal: -40,
        battery_charge: 0.0,
        battery_voltage: 3.0,
        charging: false,
        refresh_rate: 500,
        image_cached: false,
        image_timeout: 5,
        display_compatibility: false,
        display_profile: "default",
        command: "none",
        touch_bar: "tap",
        sleep_start_at: "05:00:00",
        sleep_stop_at: "10:00:00",
        width: 800,
        height: 480,
        synced_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      )
    end
  end
end
