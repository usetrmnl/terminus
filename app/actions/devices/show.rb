# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The show action.
      class Show < Action
        include Deps[:htmx_layout, repository: "repositories.device"]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view,
                          device: repository.find(parameters[:id]),
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
