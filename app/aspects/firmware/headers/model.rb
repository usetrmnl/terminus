# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Aspects
    module Firmware
      module Headers
        KEY_MAP = {
          HTTP_ACCESS_TOKEN: :api_key,
          HTTP_BATTERY_VOLTAGE: :battery_voltage,
          HTTP_FW_VERSION: :firmware_version,
          HTTP_HEIGHT: :height,
          HTTP_HOST: :host,
          HTTP_ID: :mac_address,
          HTTP_IMAGE_CACHED: :image_cached,
          HTTP_MODEL: :model_name,
          HTTP_PERCENT_CHARGED: :battery_charge,
          HTTP_REFRESH_RATE: :refresh_rate,
          HTTP_RSSI: :wifi_signal,
          HTTP_SENSORS: :sensors,
          HTTP_TEMPERATURE_PROFILE: :firmware_profile,
          HTTP_UPDATE_SOURCE: :wake_reason,
          HTTP_USB_CONNECTED: :charging,
          HTTP_USER_AGENT: :user_agent,
          HTTP_WAKE_TIME: :wake_duration,
          HTTP_WIDTH: :width,
          HTTP_WIFI_BAND: :wifi_band
        }.freeze

        # Models the HTTP headers for quick access to attributes.
        Model = Struct.new(*KEY_MAP.values) do
          using Refinements::Hash

          def self.for headers, key_map: KEY_MAP
            headers.transform_keys(key_map).then { new(**it) }
          end

          def initialize(**)
            super
            freeze
          end

          def computed_mac_address = mac_address || api_key

          def device_attributes
            {
              battery_charge:,
              battery_voltage:,
              charging:,
              firmware_profile:,
              firmware_version: firmware_version.to_s,
              height:,
              image_cached:,
              wake_duration:,
              wake_reason:,
              width:,
              wifi_band:,
              wifi_signal:
            }.compress
          end
        end
      end
    end
  end
end
