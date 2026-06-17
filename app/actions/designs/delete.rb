# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      # The delete action.
      class Delete < Action
        include Deps[
          :htmx_layout,
          template_repository: "repositories.screen_template",
          view: "views.designs.index"
        ]

        params { required(:id).filled :integer }

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          template_repository.delete parameters[:id]

          response.render view,
                          templates: template_repository.all,
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
