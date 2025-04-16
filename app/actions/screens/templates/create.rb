# frozen_string_literal: true

module Terminus
  module Actions
    module Screens
      module Templates
        # The create action.
        class Create < Terminus::Action
          include Deps[:settings, repository: "repositories.screen_template"]

          params do
            required(:template).hash do
              required(:label).filled :string
              required(:content).filled :string
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              repository.create parameters[:template]
              # response.render index_view, **view_settings(request, parameters)
            else
              render_new response, parameters
            end
          end
        end
      end
    end
  end
end
