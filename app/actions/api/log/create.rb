# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Log
        # The create action.
        class Create < Base
          include Deps[
            :logger,
            transformer: "aspects.firmware.log_transformer",
            device_repository: "repositories.device",
            log_repository: "repositories.device_log"
          ]

          using Refines::Actions::Response

          params do
            required(:logs).filled(:array).each(:hash) do
              required(:battery_voltage).filled :float
              required(:created_at).filled :integer
              required(:firmware_version).filled :string
              required(:free_heap_size).filled :integer
              required(:id).filled :integer
              optional(:level).filled Types::LogLevel
              required(:max_alloc_size).filled :integer
              required(:message).filled :string
              required(:refresh_rate).filled :integer
              optional(:retry).filled :integer
              required(:sleep_duration).filled :integer
              required(:source_line).filled :integer
              required(:source_path).filled :string
              required(:special_function).filled :string
              required(:wake_reason).filled :string
              required(:wifi_signal).filled :integer
              required(:wifi_status).filled :string
            end
          end

          def handle request, response
            parameters = request.params
            device = device_repository.find_by api_key: request.get_header("HTTP_ACCESS_TOKEN")

            return not_found response unless device
            return unprocessable_content parameters, response unless parameters.valid?

            save device, parameters, response
          end

          protected

          def authorize(*) = nil

          private

          def save device, parameters, response
            transformer.call(parameters.to_h).each do |attributes|
              log_repository.create attributes.merge!(device_id: device.id)
            end

            response.status = 204
          end

          def not_found response
            logger.error translate(".no_device")

            response.with_details problem[
              type: "/problem_details#device_id",
              status: __method__,
              detail: translate(".invalid_device_id"),
              instance: "/api/log"
            ]
          end

          def unprocessable_content parameters, response
            errors = parameters.errors.to_h

            logger.error errors

            response.with_details problem[
              type: "/problem_details#log_payload",
              status: __method__,
              detail: translate(".invalid_payload"),
              instance: "/api/log",
              extensions: {errors:}
            ]
          end
        end
      end
    end
  end
end
