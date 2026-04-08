# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      module Clone
        # The create action.
        class Create < Action
          include Deps["aspects.extensions.cloner", repository: "repositories.extension"]

          using Refinements::Hash

          params do
            required(:extension_id).filled :integer
            required(:extension).filled Schemas::Extensions::Upsert
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              save parameters, response
            else
              error parameters, parameters.errors[:extension], response
            end
          end

          private

          def save parameters, response
            case cloner.call parameters[:extension_id], **parameters[:extension]
              in Success then response.redirect_to routes.path(:extensions)
              in Failure(errors) then error parameters, errors, response
              # :nocov:
              # :nocov:
            end
          end

          def error parameters, errors, response
            fields = parameters[:extension].transform_with!(
              start_at: -> value { value.strftime("%Y-%m-%dT%H:%M:%S") }
            )

            response.render view,
                            extension: repository.find(parameters[:extension_id]),
                            fields:,
                            errors:
          end
        end
      end
    end
  end
end
