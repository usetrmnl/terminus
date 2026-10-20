# frozen_string_literal: true

require "csv"
require "initable"

module Terminus
  module Aspects
    module Devices
      # Bulk imports devices.
      class Importer
        include Deps["aspects.devices.provisioner"]
        include Initable[parser: CSV]

        HEADERS = {
          "Label" => :label,
          "Model Name" => :model_name,
          "Playlist Name" => :playlist_name,
          "MAC Address" => :mac_address,
          "API Key" => :api_key,
          "Refresh Rate" => :refresh_rate,
          "Image Timeout" => :image_timeout,
          "Firmware Update" => :firmware_update,
          "Display Compatibility" => :device_compatibility,
          "Display Profile" => :display_profile,
          "Command" => :command,
          "Touch Bar" => :touch_bar,
          "Sleep Start" => :sleep_start,
          "Sleep Stop" => :sleep_stop
        }.freeze

        def initialize(headers: HEADERS, **)
          @headers = headers
          super(**)
        end

        def call content
          content
        end

        private

        attr_reader :headers
      end
    end
  end
end
