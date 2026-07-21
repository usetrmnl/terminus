# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Firmware::LogTransformer do
  subject(:firmware_log) { described_class.new }

  let :payload do
    {
      logs: [
        {
          battery_voltage: 4.772,
          created_at: 1742000523,
          firmware_version: "1.2.3",
          free_heap_size: 210000,
          id: 1,
          message: "Danger!",
          refresh_rate: 500,
          retry: 2,
          sleep_duration: 50,
          source_line: 5,
          source_path: "src/bl.cpp",
          special_function: "none",
          wake_reason: "timer",
          wifi_signal: -54,
          wifi_status: "connected"
        }
      ]
    }
  end

  describe "#call" do
    it "answers transformed attributes" do
      expect(firmware_log.call(payload)).to eq(
        [
          {
            battery_voltage: 4.772,
            created_at: Time.utc(2025, 3, 15, 1, 2, 3),
            external_id: 1,
            firmware_version: "1.2.3",
            free_heap_size: 210000,
            message: "Danger!",
            refresh_rate: 500,
            retry: 2,
            sleep_duration: 50,
            source_line: 5,
            source_path: "src/bl.cpp",
            command: "none",
            wake_reason: "timer",
            wifi_signal: -54,
            wifi_status: "connected"
          }
        ]
      )
    end

    it "answers empty array when log key is missing" do
      expect(firmware_log.call({})).to eq([])
    end

    it "answers empty array when logs array key is missing" do
      expect(firmware_log.call({log: {}})).to eq([])
    end
  end
end
