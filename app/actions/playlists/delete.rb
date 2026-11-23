# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      # The delete action.
      class Delete < Action
        include Deps[repository: "repositories.playlist"]

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
