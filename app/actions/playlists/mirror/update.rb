# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Mirror
        # The update action.
        class Update < Action
          include Deps[
            :htmx,
            :htmx_layout,
            repository: "repositories.playlist",
            device_repository: "repositories.device",
            playlist_item_repository: "repositories.playlist_item",
            view: "views.playlists.show"
          ]

          params do
            required(:id).filled :integer
            optional(:mirror).filled(:hash) { required(:device_ids).array :integer }
          end

          def handle request, response
            parameters = request.params
            playlist = repository.find parameters[:id]

            halt :not_found unless playlist

            mirror playlist, parameters
            render playlist, request, response
          end

          private

          def mirror playlist, parameters
            device_repository.mirror_playlist parameters.dig(:mirror, :device_ids), playlist.id
          end

          def render playlist, request, response
            id = playlist.id

            htmx.response! response.headers, push_url: routes.path(:playlist, id:)
            response.render view,
                            playlist:,
                            items: playlist_item_repository.where(id: id),
                            layout: htmx_layout.call(request)
          end
        end
      end
    end
  end
end
