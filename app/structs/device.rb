# frozen_string_literal: true

require "core"
require "refinements/hash"

module Terminus
  module Structs
    # The device struct.
    class Device < DB::Struct
      using Refinements::Hash

      def asleep? at = Time.now, type: Sequel::SQLTime
        return false unless sleep_start_at && sleep_stop_at

        now = type.create at.hour, at.min, at.sec

        if sleep_stop_at < sleep_start_at
          now >= sleep_start_at || now <= sleep_stop_at
        else
          (sleep_start_at..sleep_stop_at).cover? now
        end
      end

      def battery_percentage
        battery_charge.positive? ? battery_charge : battery_voltage_to_percent
      end

      def display_attributes
        {
          image_url_timeout: image_timeout,
          maximum_compatibility: display_compatibility,
          refresh_rate:,
          temperature_profile: display_profile,
          touchbar_mode: touch_bar,
          update_firmware: firmware_update,
          reset_firmware: firmware_reset
        }
      end

      def liquid_attributes = {id:, battery_percentage:, wifi_percentage:}.stringify_keys!

      def slug
        return Core::EMPTY_STRING unless mac_address

        mac_address.tr ":", Core::EMPTY_STRING
      end

      def screen_label(prefix) = "#{prefix} #{id}"

      def screen_name(kind) = "#{kind}_#{id}"

      def screen_attributes kind
        {
          device_id: id,
          model_id:,
          label: screen_label(kind.capitalize),
          name: screen_name(kind),
          kind:
        }
      end

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

      private

      def battery_voltage_to_percent
        raw = ((battery_voltage - 3) / 0.012).round 2

        return 0 if raw.negative?

        case raw
          when 88.. then 100
          when 85.. then 95
          when 83.. then 90
          when 10.. then raw.round 2
          else 1
        end
      end
    end
  end
end
