# frozen_string_literal: true

module Terminus
  module Actions
    module Bulk
      module Devices
        module Logs
          # The delete action.
          class Delete < Action
            include Deps[:htmx_layout, repository: "repositories.device_log"]

            params { required(:device_id).filled :integer }

            protected

            def handle request, response
              parameters = request.params

              halt :unprocessable_content unless parameters.valid?

              repository.delete_all_by_device parameters[:device_id]
              response.render view, layout: htmx_layout.call(request)
            end
          end
        end
      end
    end
  end
end
