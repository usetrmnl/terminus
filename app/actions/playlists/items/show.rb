# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The show action.
        class Show < Action
          include Deps[repository: "repositories.playlist_item"]

          params do
            required(:playlist_id).filled :integer
            required(:id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            item = repository.find_by playlist_id: parameters[:playlist_id], id: parameters[:id]

            response.render view, item:, layout: false
          end
        end
      end
    end
  end
end
