# frozen_string_literal: true

require "core"

module Terminus
  module Structs
    # The device struct.
    class Device < DB::Struct
      def asleep? at = Time.now, type: Sequel::SQLTime
        return false unless sleep_start_at && sleep_stop_at

        now = type.create at.hour, at.min, at.sec

        if sleep_stop_at < sleep_start_at
          now >= sleep_start_at || now <= sleep_stop_at
        else
          (sleep_start_at..sleep_stop_at).cover? now
        end
      end

      def display_attributes
        {
          image_url_timeout: image_timeout,
          maximum_compatibility: display_compatibility,
          refresh_rate:,
          temperature_profile: display_profile,
          touchbar_mode: touch_bar,
          update_firmware: firmware_update
        }
      end

      def slug
        return Core::EMPTY_STRING unless mac_address

        mac_address.tr ":", Core::EMPTY_STRING
      end

      def screen_label(prefix) = "#{prefix} #{friendly_id}"

      def screen_name(kind) = "terminus_#{kind}_#{friendly_id.downcase}"

      def screen_attributes kind
        {
          model_id:,
          name: screen_name(kind),
          label: screen_label(kind.capitalize)
        }
      end
    end
  end
end
