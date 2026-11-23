# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The delete action.
      class Delete < Action
        include Deps[repository: "repositories.model"]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          repository.delete parameters[:id]
          response.body = ""
        end
      end
    end
  end
end
