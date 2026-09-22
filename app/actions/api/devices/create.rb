# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Devices
        # The create action.
        class Create < Base
          include Deps["aspects.devices.provisioner"]
          include Initable[serializer: Serializers::Device]

          using Refines::Actions::Response

          contract Contracts::Devices::Create

          def handle request, response
            parameters = request.params

            if parameters.valid?
              process parameters, response
            else
              unprocessable_content parameters, response
            end
          end

          private

          def process parameters, response
            case provisioner.call(**parameters[:device])
              in Success(device) then response.body = {data: serializer.new(device).to_h}.to_json
              in Failure(String => error) then not_found error, response
            end
          end

          def not_found error, response
            response.with_details problem[
              type: "/problem_details#device_payload",
              status: __method__,
              detail: error,
              instance: "/api/devices"
            ]
          end

          def unprocessable_content parameters, response
            response.with_details problem[
              type: "/problem_details#device_payload",
              status: :unprocessable_content,
              detail: translate("api.shared.errors.validation"),
              instance: "/api/devices",
              extensions: {errors: parameters.errors.to_h}
            ]
          end
        end
      end
    end
  end
end
