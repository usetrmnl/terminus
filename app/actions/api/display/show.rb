# frozen_string_literal: true

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
            firmware_repository: "repositories.firmware"
          ]

          include Initable[model: TRMNL::API::Models::Display]

          using Refines::Actions::Response

          def handle request, response
            environment = request.env

            case synchronizer.call environment
              in Success(device) then interrupt device, environment["HTTP_UPDATE_SOURCE"], response
              else not_found response
            end
          end

          protected

          def authorize(*) = nil

          private

          def interrupt device, trigger, response
            interrupter.call(device, trigger:)
                       .either -> screen { success device, screen, response },
                               -> message { error_for device, message, response }
          end

          def success device, screen, response
            attributes = {
              filename: screen.image_name_with_timestamp,
              image_url: screen.image_uri(host: settings.api_uri)
            }

            response.body = build_payload(device, attributes).to_json
          end

          def error_for device, message, response
            error.call(device, message).bind { |screen| any_error device, screen, response }
          end

          def build_payload device, attributes
            model[**fetch_firmware(device), **attributes, **device.display_attributes]
          end

          def fetch_firmware device
            firmware_repository.latest.then do |firmware|
              break unless firmware

              version = firmware.version

              break if device.firmware_version == version

              {
                firmware_url: firmware.attachment_uri(host: settings.api_uri),
                firmware_version: version
              }
            end
          end

          def any_error device, screen, response
            payload = model[
              filename: screen.image_name,
              image_url: screen.image_uri(host: settings.api_uri),
              **fetch_firmware(device),
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
