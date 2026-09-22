# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The patch action.
        class Patch < Base
          include Deps["aspects.extensions.updater", validator: "contracts.api.extensions.patch"]
          include Initable[serializer: Serializers::Extension]

          using Refines::Actions::Response

          def handle request, response
            case updater.call(request.params.to_h, validator:)
              in Success(extension) then success extension, response
              in Failure(String) then not_found response
              in Failure(*tuple) then unprocessable_content(*tuple, response)
            end
          end

          private

          def success extension, response
            response.with body: {data: serializer.new(extension).to_h}.to_json
          end

          def not_found(response) = response.with_details problem[status: :not_found]

          def unprocessable_content _extension, result, response
            response.with_details problem[
              type: "/problem_details#extension_payload",
              status: :unprocessable_content,
              detail: translate("api.shared.errors.validation"),
              instance: "/api/extensions",
              extensions: {errors: result.errors.to_h}
            ]
          end
        end
      end
    end
  end
end
