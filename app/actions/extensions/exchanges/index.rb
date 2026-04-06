# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The index action.
        class Index < Action
          include Deps[
            :htmx,
            extension_repository: "repositories.extension",
            repository: "repositories.extension_exchange"
          ]

          def handle request, response
            response.render view, **view_settings(request)
          end

          def view_settings request
            parameters = request.params
            extension = extension_repository.find parameters[:extension_id]

            settings = {extension:, exchanges: repository.where(extension_id: extension.id)}
            settings[:layout] = false if htmx.request? request.env, :request, "true"
            settings
          end
        end
      end
    end
  end
end
