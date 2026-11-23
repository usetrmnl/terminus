# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      module Clone
        # The new action.
        class New < Action
          include Deps[repository: "repositories.model"]

          protected

          def handle request, response
            model = repository.find request.params[:id]
            fields = {label: "#{model.label} Clone", name: "#{model.name}_clone"}

            response.render view, model:, fields:
          end
        end
      end
    end
  end
end
