# frozen_string_literal: true

module Terminus
  module Actions
    module Designs
      # The new action.
      class New < Action
        include Deps[
          :htmx_layout,
          template_relation: "relations.screen_template",
          model_repository: "repositories.model"
        ]

        def handle request, response
          response.render view,
                          models: model_repository.all,
                          template: with_welcome,
                          layout: htmx_layout.call(request)
        end

        private

        def with_welcome
          content = config.root_directory.join("app/templates/designs/_welcome.html.erb").read
          Struct.new(*template_relation.columns).new(content:)
        end
      end
    end
  end
end
