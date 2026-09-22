# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Devices
        # The patch action.
        class Patch < Base
          include Deps[repository: "repositories.device"]
          include Initable[serializer: Serializers::Device]

          using Refines::Actions::Response

          contract Contracts::Devices::Patch

          def handle request, response
            parameters = request.params

            if parameters.valid?
              device = repository.update(*parameters.to_h.values_at(:id, :device))
              response.body = {data: serializer.new(device).to_h}.to_json
            else
              unprocessable_content parameters, response
            end
          end

          private

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
