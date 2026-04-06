# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The new action.
        class New < Action
          include Deps[:htmx, extension_repository: "repositories.extension"]

          params { required(:extension_id).filled :integer }

          def handle request, response
            parameters = request.params

            halt 422 unless parameters.valid?

            response.render view, **view_settings(request, parameters)
          end

          private

          def view_settings request, parameters
            settings = {
              extension: extension_repository.find(parameters[:extension_id]),
              fields: {verb: "get"}
            }

            settings[:layout] = false if htmx.request? request.env, :request, "true"
            settings
          end
        end
      end
    end
  end
end
