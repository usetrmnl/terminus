# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      module Export
        # The show action.
        class Show < Action
          config.formats.accept :yml

          include Deps["aspects.extensions.exporter", repository: "repositories.extension"]

          using Refinements::Hash
          using Refines::Actions::Response

          params { required(:extension_id).filled :integer }

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            extension = repository.find parameters[:extension_id]

            case exporter.call extension
              in Success(body) then response.with body: body.deep_stringify_keys!.to_yaml
              in Failure(message) then response.with body: {"error" => message}.to_yaml
              # :nocov:
              # :nocov:
            end
          end
        end
      end
    end
  end
end
