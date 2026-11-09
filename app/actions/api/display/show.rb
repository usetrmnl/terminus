# frozen_string_literal: true

require "core"
require "trmnl/api"

module Terminus
  module Actions
    module API
      module Display
        # The show action.
        # :reek:DataClump
        class Show < Base
          include Deps[
            :settings,
            "aspects.devices.synchronizer",
            "aspects.screens.interrupter",
            "aspects.screens.interrupts.error",
            firmware_finder: "aspects.firmware.finder"
          ]

          include Initable[model: TRMNL::API::Models::Display]

          using Refines::Actions::Response

          def handle request, response
            environment = request.env
            event = environment["HTTP_SPECIAL_FUNCTION"] || environment["HTTP_UPDATE_SOURCE"]

            case synchronizer.call environment
              in Success(device) then interrupt device, event, response
              else not_found response
            end
          end

          protected

          def authorize(*) = nil

          private

          def interrupt device, event, response
            case interrupter.call(device, event:)
              in Success(screen) then success event, device, screen, response
              in Failure(message) then error_for device, message, response
            end
          end

          # rubocop:todo-next Metrics/ParameterLists
          def success event, device, screen, response
            attributes = {
              filename: screen.image_name_with_timestamp,
              image_url: screen.image_uri(host: settings.api_uri),
              action: event
            }

            response.body = build_payload(device, attributes).to_json
          end

          def build_payload device, attributes
            model[**add_firmware(device), **attributes, **device.display_attributes]
          end

          # :reek:FeatureEnvy
          def add_firmware device
            case firmware_finder.call model_id: device.model_id
              in Success(firmware)
                update = device.firmware_update && (device.firmware_version != firmware.version)

                {
                  firmware_url: firmware.attachment_uri(host: settings.api_uri),
                  update_firmware: update
                }
              else Core::EMPTY_HASH
            end
          end

          def error_for device, message, response
            error.call(device, message).bind { |screen| any_error device, screen, response }
          end

          def any_error device, screen, response
            payload = model[
              filename: screen.image_name,
              image_url: screen.image_uri(host: settings.api_uri),
              **add_firmware(device),
              **device.display_attributes
            ]

            response.body = payload.to_json
          end

          def not_found response
            response.with_details problem[
              type: "/problem_details#api_key",
              status: __method__,
              detail: translate(".invalid_api_key"),
              instance: "/api/display"
            ]
          end
        end
      end
    end
  end
end
