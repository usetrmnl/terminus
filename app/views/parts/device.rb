# frozen_string_literal: true

require "hanami/view"
require "refinements/struct"

module Terminus
  module Views
    module Parts
      # The device presenter.
      class Device < Hanami::View::Part
        include Deps["aspects.screens.fetcher", "aspects.screens.placeholder"]

        using Refinements::Struct

        def battery_percentage
          battery_charge.positive? ? battery_charge : battery_voltage_to_percent
        end

        def formatted_display_profile = display_profile.capitalize

        def formatted_touch_bar = touch_bar.capitalize

        def wake_description = String(wake_reason).empty? ? "Unknown." : wake_reason

        def wifi_percentage
          case wifi_signal
            when 0 then 0
            when ..-91 then 10
            when -90..-81 then 20
            when -80..-71 then 30
            when -70..-67 then 40
            when -66..-62 then 50
            when -61..-57 then 60
            when -56..-52 then 70
            when -51..-47 then 80
            when -46..-40 then 90
            else 100
          end
        end

        def dimensions = "#{width}x#{height}"

        def current_screen
          fetcher.call(value).either -> screen { screen },
                                     proc { placeholder.with id: id }
        end

        private

        def battery_voltage_to_percent
          case battery_voltage
            when 0 then 0
            when ..0.45 then 10
            when ..0.9 then 20
            when ..1.35 then 30
            when ..1.8 then 40
            when ..2.25 then 50
            when ..2.7 then 60
            when ..3.15 then 70
            when ..3.6 then 80
            when ..4.05 then 90
            else 100
          end
        end
      end
    end
  end
end
