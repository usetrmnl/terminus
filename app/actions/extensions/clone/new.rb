# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Clone
        # The new action.
        class New < Hanami::Action
          include Deps[repository: "repositories.extension"]

          params { required(:id).filled :integer }

          protected

          def handle request, response
            extension = repository.find request.params[:id]
            fields = {label: "#{extension.label} Clone", name: "#{extension.name}_clone"}

            response.render view, extension:, fields:
          end
        end
      end
    end
  end
end
