# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Models
    module Firmware
      KEY_MAP = {
        HTTP_ACCESS_TOKEN: :api_key,
        HTTP_BATTERY_VOLTAGE: :battery,
        HTTP_FW_VERSION: :firmware_version,
        HTTP_HEIGHT: :height,
        HTTP_HOST: :host,
        HTTP_ID: :mac_address,
        HTTP_MODEL: :model_name,
        HTTP_REFRESH_RATE: :refresh_rate,
        HTTP_RSSI: :wifi,
        HTTP_SENSORS: :sensors,
        HTTP_USER_AGENT: :user_agent,
        HTTP_WIDTH: :width
      }.freeze

      # Models the HTTP headers for quick access to attributes.
      Header = Struct.new(*KEY_MAP.values) do
        using Refinements::Hash

        def self.for(headers, key_map: KEY_MAP) = headers.transform_keys(key_map).then { new(**it) }

        def initialize(**)
          super
          freeze
        end

        def device_attributes
          {battery:, firmware_version: firmware_version.to_s, wifi:, width:, height:}.compress
        end
      end
    end
  end
end
