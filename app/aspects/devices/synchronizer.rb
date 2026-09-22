# frozen_string_literal: true

require "dry/monads"
require "pipeable"

module Terminus
  module Aspects
    module Devices
      # Updates device based on firmware header information.
      class Synchronizer
        include Deps[
          :settings,
          :i18n,
          firmware_parser: "aspects.firmware.headers.parser",
          repository: "repositories.device"
        ]
        include Pipeable
        include Dry::Monads[:result]

        def call(headers) = pipe firmware_parser.call(headers), :update

        private

        def update result, at: Time.now
          result.bind do |model|
            device = repository.update_by_api_key model.api_key,
                                                  **model.device_attributes,
                                                  synced_at: at
            message = i18n.translate "aspects.devices.synchronizer.invalid_api_key"

            device ? Success(device) : Failure(message)
          end
        end
      end
    end
  end
end
