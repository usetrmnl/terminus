# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The new action.
        class New < Action
          include Deps[:htmx_layout, extension_repository: "repositories.extension"]

          params { required(:extension_id).filled :integer }

          protected

          def handle request, response
            parameters = request.params

            halt 422 unless parameters.valid?

            response.render view, **view_settings(request, parameters)
          end

          private

          def view_settings request, parameters
            {
              extension: extension_repository.find(parameters[:extension_id]),
              fields: {verb: "get"},
              layout: htmx_layout.call(request)
            }
          end
        end
      end
    end
  end
end
