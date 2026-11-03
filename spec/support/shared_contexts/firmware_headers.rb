# frozen_string_literal: true

RSpec.shared_context "with firmware headers" do
  let :firmware_headers do
    {
      "HTTP_ACCESS_TOKEN" => "abc123",
      "HTTP_BATTERY_CAPACITY" => "4860/6000",
      "HTTP_BATTERY_CHARGING" => "0",
      "HTTP_BATTERY_COUNT" => "1",
      "HTTP_BATTERY_CURRENT" => "-55",
      "HTTP_BATTERY_HEALTH" => "-1",
      "HTTP_BATTERY_TEMP" => "20.50",
      "HTTP_BATTERY_VOLTAGE" => "4.74",
      "HTTP_FW_VERSION" => "1.2.3",
      "HTTP_GAUGE_CAPACITY" => "4303/5765",
      "HTTP_GAUGE_HEALTH" => "95",
      "HTTP_GAUGE_SOC" => "75",
      "HTTP_HEIGHT" => "480",
      "HTTP_HOST" => "https://localhost",
      "HTTP_ID" => "A1:B2:C3:D4:E5:F6",
      "HTTP_IMAGE_CACHED" => "false",
      "HTTP_MODEL" => "og",
      "HTTP_PERCENT_CHARGED" => "85",
      "HTTP_REFRESH_RATE" => "25",
      "HTTP_RSSI" => "-54",
      "HTTP_SENSORS" => "make=Sensirion;model=SCD41;kind=humidity;" \
                        "value=26;unit=percent;created_at=1735714800",
      "HTTP_SPECIAL_FUNCTION" => "identify",
      "HTTP_TEMPERATURE_PROFILE" => "true",
      "HTTP_UPDATE_SOURCE" => "Button pressed.",
      "HTTP_USB_CONNECTED" => "false",
      "HTTP_USER_AGENT" => "ESP32HTTPClient",
      "HTTP_WAKE_TIME" => "20",
      "HTTP_WIDTH" => "800",
      "HTTP_WIFI_BAND" => "2.4"
    }
  end
end
