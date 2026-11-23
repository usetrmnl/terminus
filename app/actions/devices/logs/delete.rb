# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      module Logs
        # The delete action.
        class Delete < Action
          include Deps[repository: "repositories.device_log"]

          params do
            required(:device_id).filled :integer
            required(:id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            repository.delete_by_device(*parameters.to_h.values_at(:device_id, :id))
            response.body = ""
          end
        end
      end
    end
  end
end
