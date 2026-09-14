# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The new action.
        class New < Action
          include Deps[
            playlist_repository: "repositories.playlist",
            screen_repository: "repositories.screen"
          ]

          params { required(:playlist_id).filled :integer }

          def handle request, response
            parameters = request.params

            halt 422 unless parameters.valid?

            playlist = playlist_repository.find parameters[:playlist_id]

            response.render view,
                            playlist:,
                            screens: screen_repository.all,
                            screen_selection:,
                            layout: false
          end

          private

          def screen_selection = screen_repository.all.first.then { it.label if it }
        end
      end
    end
  end
end
