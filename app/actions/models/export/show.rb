# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      module Export
        # The show action.
        class Show < Action
          config.formats.accept :zip

          include Deps["aspects.models.exporter", repository: "repositories.model"]

          using Refines::Actions::Response

          params { required(:id).filled :integer }

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            model = repository.find parameters[:id]

            case exporter.call model
              in Success(body) then response.with body: body.read
              in Failure(message) then response.with body: message, status: 500
            end
          end
        end
      end
    end
  end
end
