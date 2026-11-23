# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The index action.
        class Index < Action
          include Deps[repository: "repositories.playlist_item"]

          protected

          def handle request, response
            parameters = request.params
            playlist_id = parameters[:playlist_id]

            response.render view, playlist_id:, items: repository.where(playlist_id:), layout: false
          end
        end
      end
    end
  end
end
