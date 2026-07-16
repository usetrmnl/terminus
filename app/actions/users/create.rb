# frozen_string_literal: true

module Terminus
  module Actions
    module Users
      # The create action.
      class Create < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.user",
          status_repository: "repositories.user_status",
          creator: "aspects.users.creator",
          index_view: "views.users.index"
        ]

        def handle request, response
          case creator.call(**request.params.to_h.slice(:user))
            in Success(Structs::User)
              response.render index_view, users: repository.all, layout: htmx_layout.call(request)
            in Failure(result) then error request, response, result
          end
        end

        private

        def error request, response, result
          response.render view,
                          user: repository.find(request.params[:id]),
                          statuses: status_repository.all,
                          fields: result[:user],
                          errors: result.errors[:user],
                          layout: false
        end
      end
    end
  end
end
