# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The update action.
      class Update < Action
        include Deps[:htmx_layout, repository: "repositories.model", show_view: "views.models.show"]

        contract Contracts::Models::Update

        protected

        def handle request, response
          parameters = request.params
          model = repository.find parameters[:id]

          halt :unprocessable_content unless model

          if parameters.valid?
            save request, response
          else
            render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params

          response.render view,
                          model: repository.find(parameters[:id]),
                          fields: parameters[:model],
                          errors: parameters.errors[:model],
                          layout: htmx_layout.call(request)
        end

        private

        def save request, response
          parameters = request.params
          id = parameters[:id]

          repository.update id, **parameters[:model]

          response.render show_view, model: repository.find(id), layout: htmx_layout.call(request)
        end
      end
    end
  end
end
