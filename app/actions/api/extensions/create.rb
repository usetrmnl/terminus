# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The create action.
        class Create < Base
          include Deps["aspects.extensions.creator", validator: "contracts.api.extensions.create"]
          include Initable[serializer: Serializers::Extension]

          using Refines::Actions::Response

          def handle request, response
            case creator.call(request.params.to_h, validator:)
              in Success(extension) then success extension, response
              in Failure(result) then failure result, response
            end
          end

          private

          def success extension, response
            response.with body: {data: serializer.new(extension).to_h}.to_json
          end

          def failure result, response
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
