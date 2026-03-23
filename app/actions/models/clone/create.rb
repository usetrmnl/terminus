# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      module Clone
        # The create action.
        class Create < Action
          include Deps["aspects.models.cloner", repository: "repositories.model"]

          contract Contracts::Models::Clone

          def handle request, response
            parameters = request.params

            if parameters.valid?
              clone parameters, response
            else
              render_form_error parameters, parameters.errors[:model], response
            end
          end

          private

          def clone parameters, response
            case cloner.call parameters[:model_id], **parameters[:model]
              in Success then response.redirect_to routes.path(:models)
              in Failure(errors) then render_form_error parameters, errors, response
              # :nocov:
              # :nocov:
            end
          end

          def render_form_error parameters, errors, response
            id, fields = parameters.to_h.values_at :model_id, :model
            response.render view, model: repository.find(id), fields:, errors:
          end
        end
      end
    end
  end
end
