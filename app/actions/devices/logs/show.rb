# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      module Logs
        # The show action.
        class Show < Action
          include Deps[
            device_repository: "repositories.device",
            repository: "repositories.device_log"
          ]

          params do
            required(:device_id).filled :integer
            required(:id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            device = device_repository.find parameters[:device_id]
            log = repository.find parameters[:id]

            response.render view, device:, log:
          end
        end
      end
    end
  end
end
