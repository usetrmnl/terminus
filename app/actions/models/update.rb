# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The update action.
      class Update < Action
        include Deps[repository: "repositories.model", show_view: "views.models.show"]

        contract Contracts::Models::Update

        protected

        def handle request, response
          parameters = request.params
          model = repository.find parameters[:id]

          halt :unprocessable_content unless model

          if parameters.valid?
            save model, parameters, response
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
                          layout: false
        end

        private

        def save model, parameters, response
          id = model.id
          repository.update id, **parameters[:model]

          response.render show_view, model: repository.find(id), layout: false
        end
      end
    end
  end
end
