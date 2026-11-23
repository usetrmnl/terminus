# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      # The create action.
      class Create < Terminus::Action
        include Deps[
          "aspects.screens.upserter",
          repository: "repositories.screen_template",
          model_repository: "repositories.model"
        ]

        params do
          required(:model_id).filled :integer

          required(:design).hash do
            required(:label).filled :string
            required(:name).filled :string
            required(:mode).filled :string
            required(:content).filled :string
          end
        end

        protected

        def handle request, response
          parameters = request.params

          if parameters.valid?
            create_with_screen parameters, response
          else
            render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params
          errors = parameters.errors

          response.render view,
                          models: model_repository.all,
                          template: nil,
                          fields: parameters[:design],
                          errors: errors[:design] || errors
        end

        private

        def create_with_screen parameters, response
          screen_template = repository.create parameters[:design]

          upserter.call(model_id: parameters[:model_id], **screen_template.screen_attributes)
          response.redirect_to routes.path(:design_edit, id: screen_template.id)
        end
      end
    end
  end
end
