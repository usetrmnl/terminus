# frozen_string_literal: true

module Terminus
  module Views
    module Playlists
      module Screens
        # The show view.
        class Show < View
          expose :playlist
          expose :current
          expose(:index) { |screens, current:| screens.index current }
          expose(:total) { |screens| screens.size - 1 }

          expose :status do |index, total|
            "#{index + 1} of #{total + 1}" if index && total
          end

          expose :previous_uri do |playlist:, before:|
            routes.path :playlist_screen, playlist_id: playlist.id, id: before.id if before
          end

          expose :next_uri do |playlist:, after:|
            routes.path :playlist_screen, playlist_id: playlist.id, id: after.id if after
          end

          expose :first_uri do |screens, playlist:|
            first = screens.first
            routes.path :playlist_screen, playlist_id: playlist.id, id: first.id if first
          end

          expose :last_uri do |screens, playlist:|
            last = screens.last
            routes.path :playlist_screen, playlist_id: playlist.id, id: last.id if last
          end

          private_expose :before
          private_expose :after
          private_expose(:screens) { |playlist:| playlist.screens }

          private

          def routes = rendering.context.routes
        end
      end
    end
  end
end
