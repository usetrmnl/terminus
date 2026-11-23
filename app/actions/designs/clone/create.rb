# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      module Clone
        # The create action.
        class Create < Action
          include Deps[
            "aspects.designs.cloner",
            repository: "repositories.screen_template",
            model_repository: "repositories.model"
          ]

          params do
            required(:id).filled :integer

            required(:design).hash do
              required(:label).filled :string
              required(:name).filled :string
              required(:mode).filled :string
              required(:content).filled :string
            end

            required(:model_id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            if parameters.valid?
              clone parameters, response
            else
              errors = parameters.errors
              render_form_error parameters, errors[:design], response
            end
          end

          private

          def clone parameters, response
            id, model_id, design = parameters.to_h.values_at :id, :model_id, :design

            case cloner.call id, model_id:, **design
              in Success then response.redirect_to routes.path(:designs)
              in Failure(errors) then render_form_error parameters, errors, response
            end
          end

          def render_form_error parameters, errors, response
            id, fields = parameters.to_h.values_at :id, :design
            response.render view,
                            models: model_repository.all,
                            template: repository.find(id),
                            fields:,
                            errors:
          end
        end
      end
    end
  end
end
