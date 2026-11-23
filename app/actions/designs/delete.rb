# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      # The delete action.
      class Delete < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.screen_template",
          view: "views.designs.index"
        ]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          repository.delete parameters[:id]

          response.render view, templates: repository.all, layout: htmx_layout.call(request)
        end
      end
    end
  end
end
