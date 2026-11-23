# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      # The edit action.
      class Edit < Action
        include Deps[repository: "repositories.extension"]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view, extension: repository.find(parameters[:id])
        end
      end
    end
  end
end
