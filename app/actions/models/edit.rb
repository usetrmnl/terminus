# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The edit action.
      class Edit < Action
        include Deps[:htmx_layout, repository: "repositories.model"]

        params { required(:id).filled :integer }

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view,
                          model: repository.find(parameters[:id]),
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
