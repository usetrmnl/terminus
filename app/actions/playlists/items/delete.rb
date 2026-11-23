# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The delete action.
        class Delete < Action
          include Deps[repository: "repositories.playlist_item"]

          params do
            required(:playlist_id).filled :integer
            required(:id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            item = repository.find_by(**parameters)
            repository.delete item.id
            response.body = ""
          end
        end
      end
    end
  end
end
