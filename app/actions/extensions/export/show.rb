# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Export
        # The show action.
        class Show < Action
          config.formats.accept :zip

          include Deps["aspects.extensions.exporter", repository: "repositories.extension"]

          using Refines::Actions::Response

          params { required(:extension_id).filled :integer }

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            extension = repository.find parameters[:extension_id]

            case exporter.call extension
              in Success(body) then response.with body: body.read
              in Failure(message) then response.with body: message, status: 500
            end
          end
        end
      end
    end
  end
end
