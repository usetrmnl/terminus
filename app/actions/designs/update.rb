# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Designs
      # The update action.
      class Update < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.screen_template",
          screen_repository: "repositories.screen"
        ]
        include Initable[job: Jobs::Screens::Upsert]

        using Refinements::Hash

        params do
          required(:id).filled :integer
          required(:screen_id).filled :integer

          required(:design).hash do
            required(:label).filled :string
            required(:name).filled :string
            required(:mode).filled :string
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
          attributes = parameters[:design]
          screen_template = repository.update parameters[:id], **attributes
          screen = screen_repository.find parameters[:screen_id]

          job.perform_async screen.model_id, screen_template.screen_attributes.stringify_keys!
          response.render view, template: screen_template, layout: htmx_layout.call(request)
        end

        def error request, parameters, response
          template = find_template parameters

          response.render view,
                          template: template,
                          fields: parameters[:design],
                          errors: parameters.errors[:design],
                          layout: htmx_layout.call(request)
        end

        def find_template(parameters) = repository.find parameters[:id]
      end
    end
  end
end
