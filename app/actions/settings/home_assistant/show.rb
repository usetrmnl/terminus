# frozen_string_literal: true

module Terminus
  module Actions
    module Settings
      module HomeAssistant
        # The show action.
        class Show < Action
          include Deps[:htmx_layout, repository: "repositories.home_assistant_connection"]

          def handle request, response
            response.render view,
                            connection: repository.current_or_initialize,
                            ha_fields: {},
                            errors: {},
                            layout: htmx_layout.call(request)
          end
        end
      end
    end
  end
end
