# frozen_string_literal: true

module Terminus
  module Actions
    module Settings
      module HomeAssistant
        # The test action.
        class Test < Action
          include Deps[
            repository: "repositories.home_assistant_connection",
            connection_tester: "aspects.home_assistant.connection_tester"
          ]

          def handle _request, response
            connection = repository.current
            result = connection_tester.call connection

            if result.success?
              response.flash[:notice] = "Home Assistant connection succeeded."
            else
              response.flash[:alert] = result.failure
            end

            response.redirect_to routes.path(:settings_home_assistant)
          end
        end
      end
    end
  end
end
