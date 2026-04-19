# frozen_string_literal: true

module Terminus
  module Views
    module Playlists
      module Screens
        # The show view.
        class Show < View
          include Deps[:routes]

          expose :playlist
          expose :current
          expose(:index, decorate: false) { |screens, current:| screens.index current }
          expose(:total, decorate: false) { |screens| screens.size - 1 }

          expose :status, decorate: false do |index, total|
            "#{index + 1} of #{total + 1}" if index && total
          end

          expose :previous_uri, decorate: false do |playlist:, before:|
            routes.path :playlist_screen, playlist_id: playlist.id, id: before.id if before
          end

          expose :next_uri, decorate: false do |playlist:, after:|
            routes.path :playlist_screen, playlist_id: playlist.id, id: after.id if after
          end

          expose :first_uri, decorate: false do |screens, playlist:|
            first = screens.first
            routes.path :playlist_screen, playlist_id: playlist.id, id: first.id if first
          end

          expose :last_uri, decorate: false do |screens, playlist:|
            last = screens.last
            routes.path :playlist_screen, playlist_id: playlist.id, id: last.id if last
          end

          private_expose :routes
          private_expose :before, decorate: false
          private_expose :after, decorate: false
          private_expose(:screens, decorate: false) { |playlist:| playlist.screens }
        end
      end
    end
  end
end
