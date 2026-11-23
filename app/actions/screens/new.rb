# frozen_string_literal: true

module Terminus
  module Actions
    module Screens
      # The new action.
      class New < Action
        include Deps[:htmx_layout, model_repository: "repositories.model"]

        protected

        def handle request, response
          response.render view, models: model_repository.all, layout: htmx_layout.call(request)
        end
      end
    end
  end
end
