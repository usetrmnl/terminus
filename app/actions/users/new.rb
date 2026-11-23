# frozen_string_literal: true

module Terminus
  module Actions
    module Users
      # The new action.
      class New < Action
        include Deps[:htmx_layout, status_repository: "repositories.user_status"]

        protected

        def handle request, response
          response.render view, statuses: status_repository.all, layout: htmx_layout.call(request)
        end
      end
    end
  end
end
