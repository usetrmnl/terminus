# frozen_string_literal: true

module Terminus
  module Actions
    module Screens
      # The edit action.
      class Edit < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.screen",
          model_repository: "repositories.model"
        ]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view,
                          models: model_repository.all,
                          screen: repository.find(parameters[:id]),
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
