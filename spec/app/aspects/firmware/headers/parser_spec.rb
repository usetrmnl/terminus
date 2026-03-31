# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Firmware::Headers::Parser do
  subject(:parser) { described_class.new }

  include_context "with firmware headers"
  include_context "with application dependencies"

  describe "#call" do
    let :debug_message_pattern do
      /
        DEBUG.+Processing\sdevice\srequest\sheaders.+
        HTTP_ACCESS_TOKEN.+
        HTTP_BATTERY_VOLTAGE.+
        HTTP_FW_VERSION.+
        HTTP_HEIGHT.+
        HTTP_HOST.+
        HTTP_ID.+
        HTTP_MODEL.+
        HTTP_PERCENT_CHARGE.+
        HTTP_REFRESH_RATE.+
        HTTP_RSSI.+
        HTTP_SENSORS.+
        HTTP_UPDATE_SOURCE.+
        HTTP_USER_AGENT.+
        HTTP_WIDTH.+
      /x
    end

    it "logs header information as debug message" do
      parser.call firmware_headers
      expect(logger.reread).to match(debug_message_pattern)
    end

    it "answers header record when success" do
      expect(parser.call(firmware_headers)).to be_success(
        Terminus::Models::Firmware::Header[
          host: "https://localhost",
          user_agent: "ESP32HTTPClient",
          mac_address: "A1:B2:C3:D4:E5:F6",
          model_name: "og_plus",
          api_key: "abc123",
          refresh_rate: 25,
          battery_charge: 85.0,
          battery_voltage: 4.74,
          firmware_version: "1.2.3",
          wake_reason: "Button pressed.",
          wifi: -54,
          width: 800,
          height: 480,
          sensors: [
            {
              make: "Sensirion",
              model: "SCD41",
              kind: "humidity",
              value: "26",
              unit: "percent",
              source: "device",
              created_at: Time.at(1735714800)
            }
          ]
        ]
      )
    end

    it "answers failure with invalid headers" do
      firmware_headers.delete "HTTP_ID"

      expect(parser.call(firmware_headers)).to be_failure(
        Terminus::Schemas::Firmware::Header.call(firmware_headers)
      )
    end
  end
end
