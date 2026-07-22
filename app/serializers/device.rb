# auto_register: false
# frozen_string_literal: true

module Terminus
  module Serializers
    # A device serializer for specific keys.
    class Device
      KEYS = %i[
        id
        model_id
        playlist_id
        label
        mac_address
        api_key
        firmware_profile
        firmware_update
        firmware_version
        wifi_band
        wifi_signal
        battery_charge
        battery_voltage
        charging
        refresh_rate
        image_cached
        image_timeout
        wake_reason
        wake_duration
        width
        height
        display_compatibility
        display_profile
        command
        touch_bar
        sleep_start_at
        sleep_stop_at
        synced_at
        created_at
        updated_at
      ].freeze

      def initialize record, keys: KEYS, transformer: Transformers::Time
        @record = record
        @keys = keys
        @transformer = transformer
      end

      def to_h
        attributes = record.to_h.slice(*keys)
        attributes.transform_values!(&transformer)
        attributes
      end

      private

      attr_reader :record, :keys, :transformer
    end
  end
end
