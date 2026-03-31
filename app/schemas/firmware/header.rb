# frozen_string_literal: true

module Terminus
  module Schemas
    module Firmware
      # Validates request headers.
      Header = Dry::Schema.Params do
        optional(:HTTP_ACCESS_TOKEN).maybe :string
        optional(:HTTP_BATTERY_VOLTAGE).filled :float
        optional(:HTTP_FW_VERSION).filled Types::Version
        optional(:HTTP_HEIGHT).filled :integer
        optional(:HTTP_HOST).filled :string
        required(:HTTP_ID).filled :string
        optional(:HTTP_MODEL).filled :string
        optional(:HTTP_PERCENT_CHARGED).filled :float
        optional(:HTTP_REFRESH_RATE).filled :integer
        optional(:HTTP_RSSI).filled :integer
        optional(:HTTP_SENSORS).maybe :string
        optional(:HTTP_UPDATE_SOURCE).filled :string
        optional(:HTTP_USER_AGENT).filled :string
        optional(:HTTP_WIDTH).filled :integer
      end
    end
  end
end
