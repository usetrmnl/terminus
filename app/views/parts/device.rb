# frozen_string_literal: true

require "hanami/view"

module Terminus
  module Views
    module Parts
      # The device presenter.
      class Device < Hanami::View::Part
        include Deps["aspects.screens.fetcher", "aspects.screens.placeholder"]

        def battery_measurement_label minimum_voltage: 4.2
          return "Charging" if charging || battery_voltage >= minimum_voltage

          "Battery (#{helpers.format_number battery_percentage, precision: 0}%)"
        end

        def formatted_display_profile = display_profile.capitalize

        def formatted_touch_bar = touch_bar.capitalize

        def translated_command = helpers.translate "devices.shared._fields.commands.#{command}"

        def wake_description = String(wake_reason).empty? ? "Unknown." : wake_reason

        def wifi_measurement_label
          band = wifi_band
          band.zero? ? "WiFi (#{wifi_percentage}%)" : "#{band} GHz (#{wifi_percentage}%)"
        end

        def dimensions = "#{width}x#{height}"

        def current_screen
          fetcher.call(value).either -> screen { screen },
                                     proc { placeholder.with id: id }
        end
      end
    end
  end
end
