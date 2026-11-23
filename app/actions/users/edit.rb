# frozen_string_literal: true

module Terminus
  module Actions
    module Users
      # The edit action.
      class Edit < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.user",
          status_repository: "repositories.user_status"
        ]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view,
                          user: repository.find(parameters[:id]),
                          statuses: status_repository.all,
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
