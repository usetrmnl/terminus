# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The create action.
      class Create < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.model",
          index_view: "views.models.index"
        ]

        contract Contracts::Models::Create

        protected

        def handle request, response
          parameters = request.params

          if parameters.valid?
            repository.create parameters[:model]
            response.render index_view, **view_settings(request)
          else
            render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params

          response.render view,
                          models: repository.all,
                          fields: parameters[:model],
                          errors: parameters.errors[:model],
                          layout: htmx_layout.call(request)
        end

        private

        def view_settings(request) = {models: repository.all, layout: htmx_layout.call(request)}
      end
    end
  end
end
