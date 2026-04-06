# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The edit action.
        class Edit < Action
          include Deps[
            :htmx,
            extension_repository: "repositories.extension",
            repository: "repositories.extension_exchange"
          ]

          params do
            required(:extension_id).filled :integer
            required(:id).filled :integer
          end

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            response.render view, **view_settings(request, parameters)
          end

          private

          def view_settings request, parameters
            settings = {
              extension: extension_repository.find(parameters[:extension_id]),
              exchange: repository.find_by(**parameters)
            }

            settings[:layout] = false if htmx.request? request.env, :request, "true"

            settings
          end
        end
      end
    end
  end
end
