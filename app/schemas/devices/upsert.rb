# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Devices
      # Defines device upsert schema.
      Upsert = Dry::Schema.Params do
        required(:model_id).filled :integer
        required(:playlist_id).maybe :integer
        optional(:label).filled :string
        optional(:mac_address).filled Types::MACAddress
        optional(:api_key).filled :string
        optional(:refresh_rate).filled :integer, gt?: 0
        optional(:image_cached).maybe :bool
        optional(:image_timeout).filled :integer, gteq?: 0
        optional(:display_compatibility).filled :bool
        optional(:display_profile).filled :string
        optional(:firmware_update).filled :bool
        optional(:firmware_profile).filled :bool
        optional(:firmware_version).filled Types::Version
        optional(:charging).maybe :bool
        optional(:battery_charge).filled :float, gteq?: 0
        optional(:battery_voltage).filled :float
        optional(:wifi_band).filled :float, gteq?: 0
        optional(:wifi_signal).filled :integer
        optional(:width).filled :integer
        optional(:height).filled :integer
        optional(:touch_bar).filled :string
        optional(:wake_duration).maybe :integer
        optional(:wake_reason).filled :string
        optional(:sleep_start_at).maybe :string
        optional(:sleep_stop_at).maybe :string
        optional(:synced_at).maybe :string

        after(:value_coercer, &Coercers::DefaultToFalse.curry[:charging])
        after(:value_coercer, &Coercers::DefaultToFalse.curry[:display_compatibility])
        after(:value_coercer, &Coercers::DefaultToFalse.curry[:firmware_profile])
        after(:value_coercer, &Coercers::DefaultToFalse.curry[:firmware_update])
        after(:value_coercer, &Coercers::DefaultToFalse.curry[:image_cached])
      end
    end
  end
end
