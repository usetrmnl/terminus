# frozen_string_literal: true

module Terminus
  module Actions
    module Settings
      module HomeAssistant
        # The update action.
        class Update < Action
          include Deps[
            repository: "repositories.home_assistant_connection",
            show_view: "views.settings.home_assistant.show"
          ]

          params do
            required(:home_assistant_connection).filled :hash do
              optional(:enabled).filled :bool
              required(:base_url).maybe :string
              optional(:access_token).maybe :string
              optional(:clear_access_token).filled :bool
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              save parameters[:home_assistant_connection]
              response.flash[:notice] = "Home Assistant settings saved."
              response.redirect_to routes.path(:settings_home_assistant)
            else
              render_errors response, parameters
            end
          end

          private

          def save attributes
            connection = repository.current_or_initialize
            values = base_values attributes
            assign_token values, attributes

            repository.update connection.id, values
          end

          def render_errors response, parameters
            response.render show_view,
                            connection: repository.current_or_initialize,
                            ha_fields: parameters[:home_assistant_connection],
                            errors: parameters.errors[:home_assistant_connection]
          end

          def base_values attributes
            {
              enabled: attributes.fetch(:enabled, false),
              base_url: attributes[:base_url]
            }
          end

          def assign_token values, attributes
            token = String(attributes[:access_token]).strip
            clear_access_token = attributes.fetch :clear_access_token, false

            return values[:access_token] = nil if clear_access_token

            values[:access_token] = token unless token.empty?
          end
        end
      end
    end
  end
end
