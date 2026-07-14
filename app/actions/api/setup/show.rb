# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Setup
        # The show action.
        class Show < Base
          include Deps[
            "aspects.devices.provisioner",
            firmware_parser: "aspects.firmware.headers.parser",
            model_repository: "repositories.model"
          ]
          include Initable[payload: Aspects::Firmware::Models::Setup]

          using Refines::Actions::Response

          def handle request, response
            case firmware_parser.call request.env
              in Success(model) then create model, response
              in Failure(result) then unprocessable_content result.errors.to_h, response
              # :nocov:
              # :nocov:
            end
          end

          protected

          def authorize(*) = nil

          private

          def create model, response
            provision_device(model).either proc { response.with body: payload.welcome.to_json },
                                           -> error { not_found error, response }
          end

          def provision_device model
            firmware_version, model_name = model.to_h.values_at :firmware_version, :model_name

            provisioner.call model_id: find_model_id(model_name),
                             mac_address: model.mac_address,
                             firmware_version:
          end

          def find_model_id(name) = model_repository.find_by(name:).then { it.id if it }

          def not_found error, response
            payload = petail[
              type: "/problem_details#device_setup",
              status: __method__,
              detail: error,
              instance: "/api/setup"
            ]

            response.with body: payload.to_json, format: :problem_details, status: payload.status
          end

          def unprocessable_content errors, response
            payload = petail[
              type: "/problem_details#device_setup",
              status: __method__,
              detail: "Invalid request headers.",
              instance: "/api/setup",
              extensions: {errors:}
            ]

            response.with body: payload.to_json, format: :problem_details, status: payload.status
          end
        end
      end
    end
  end
end
