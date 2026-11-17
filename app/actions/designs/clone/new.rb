# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      module Clone
        # The new action.
        class New < Action
          include Deps[
            :htmx_layout,
            repository: "repositories.screen_template",
            model_repository: "repositories.model"
          ]

          def handle request, response
            template = repository.find request.params[:id]
            fields = {label: "#{template.label} Clone", name: "#{template.name}_clone"}

            response.render view,
                            models: model_repository.all,
                            template:,
                            fields:,
                            layout: htmx_layout.call(request)
          end
        end
      end
    end
  end
end
