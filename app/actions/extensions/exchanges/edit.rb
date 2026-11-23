# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The edit action.
        class Edit < Action
          include Deps[
            :htmx_layout,
            extension_repository: "repositories.extension",
            repository: "repositories.extension_exchange"
          ]

          params do
            required(:extension_id).filled :integer
            required(:id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            response.render view, **view_settings(request, parameters)
          end

          private

          def view_settings request, parameters
            {
              extension: extension_repository.find(parameters[:extension_id]),
              exchange: repository.find_by(**parameters),
              layout: htmx_layout.call(request)
            }
          end
        end
      end
    end
  end
end
