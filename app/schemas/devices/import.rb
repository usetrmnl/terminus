# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Devices
      # Defines device import schema.
      Import = Dry::Schema.Params do
        required(:model_name).filled :string
        required(:playlist_name).filled :string
        optional(:label).filled :string
        optional(:mac_address).filled Types::MACAddress
        optional(:api_key).filled :string
        optional(:refresh_rate).filled :integer, gt?: 0
        optional(:image_timeout).filled :integer, gteq?: 0
        optional(:firmware_update).filled :bool
        optional(:display_compatibility).filled :bool
        optional(:display_profile).filled :string
        optional(:command).filled :string
        optional(:touch_bar).filled :string
        optional(:sleep_start_at).maybe :string
        optional(:sleep_stop_at).maybe :string
      end
    end
  end
end
