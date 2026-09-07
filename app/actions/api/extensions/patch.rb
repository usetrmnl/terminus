# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The patch action.
        # :reek:DataClump
        # rubocop:todo-next I18n/RailsI18n/DecorateString
        class Patch < Base
          include Deps[repository: "repositories.extension"]
          include Initable[serializer: Serializers::Extension]

          using Refines::Actions::Response

          contract Contracts::Extensions::Patch

          def handle request, response
            parameters = request.params

            if parameters.valid?
              save parameters, response
            else
              unprocessable_content_for_parameters parameters.errors.to_h, response
            end
          end

          private

          def save parameters, response
            id = parameters[:id]
            extension = repository.update id, parameters[:extension]

            if extension
              response.with body: {data: serializer.new(extension).to_h}.to_json
            else
              response.with body: problem[status: :not_found].to_json
            end
          end

          def unprocessable_content_for_parameters errors, response
            response.with_details problem[
              type: "/problem_details#extension_payload",
              status: :unprocessable_content,
              detail: "Validation failed.",
              instance: "/api/extensions",
              extensions: {errors:}
            ]
          end
        end
      end
    end
  end
end
