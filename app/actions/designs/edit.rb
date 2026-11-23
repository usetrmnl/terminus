# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      # The edit action.
      class Edit < Action
        include Deps[:htmx_layout, repository: "repositories.screen_template"]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view,
                          template: repository.find(parameters[:id]),
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
