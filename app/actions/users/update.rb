# frozen_string_literal: true

module Terminus
  module Actions
    module Users
      # The update action.
      class Update < Action
        include Deps[
          :htmx_layout,
          updater: "aspects.users.updater",
          repository: "repositories.user",
          status_repository: "repositories.user_status",
          show_view: "views.users.show"
        ]

        protected

        def handle request, response
          case updater.call(**request.params.to_h)
            in Success(user) then save request, user, response
            in Failure(result) then error request, result, response
          end
        end

        private

        def save request, user, response
          response.render show_view, user:, layout: htmx_layout.call(request)
        end

        def error request, result, response
          response.render view,
                          user: repository.find(request.params[:id]),
                          statuses: status_repository.all,
                          fields: result[:user],
                          errors: result.errors[:user],
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
