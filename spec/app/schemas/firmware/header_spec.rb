# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Schemas::Firmware::Header do
  subject(:contract) { described_class }

  include_context "with firmware headers"

  describe ".call" do
    it "answers valid contract" do
      expect(contract.call(firmware_headers).to_h).to eq(
        HTTP_ACCESS_TOKEN: "abc123",
        HTTP_BATTERY_VOLTAGE: 4.74,
        HTTP_FW_VERSION: "1.2.3",
        HTTP_HEIGHT: 480,
        HTTP_HOST: "https://localhost",
        HTTP_ID: "A1:B2:C3:D4:E5:F6",
        HTTP_IMAGE_CACHED: false,
        HTTP_MODEL: "og",
        HTTP_PERCENT_CHARGED: 85.0,
        HTTP_REFRESH_RATE: 25,
        HTTP_RSSI: -54,
        HTTP_SENSORS: "make=Sensirion;model=SCD41;kind=humidity;" \
                      "value=26;unit=percent;created_at=1735714800",
        HTTP_TEMPERATURE_PROFILE: true,
        HTTP_UPDATE_SOURCE: "Button pressed.",
        HTTP_USB_CONNECTED: false,
        HTTP_WAKE_TIME: 20,
        HTTP_WIFI_BAND: 2.4,
        HTTP_WIDTH: 800
      )
    end
  end
end
