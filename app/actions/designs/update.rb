# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      # The update action.
      # :reek:DataClump
      class Update < Action
        include Deps[
          :htmx_layout,
          "aspects.screens.upserter",
          template_repository: "repositories.screen_template",
          screen_repository: "repositories.screen"
        ]

        params do
          required(:id).filled :integer
          required(:screen_id).filled :integer

          required(:template).hash do
            required(:label).filled :string
            required(:name).filled :string
            required(:content).filled :string
          end
        end

        def handle request, response
          parameters = request.params

          if parameters.valid?
            save request, parameters, response
          else
            error request, parameters, response
          end
        end

        private

        def save request, parameters, response
          attributes = parameters[:template]
          template = template_repository.update parameters[:id], **attributes
          screen = screen_repository.find parameters[:screen_id]

          upserter.call(model_id: screen.model_id, **template.screen_attributes)

          response.render view, template: template, layout: htmx_layout.call(request)
        end

        def error request, parameters, response
          template = find_template parameters

          response.render view,
                          template: template,
                          fields: parameters[:template],
                          errors: parameters.errors[:template],
                          layout: htmx_layout.call(request)
        end

        def find_template(parameters) = template_repository.find parameters[:id]
      end
    end
  end
end
