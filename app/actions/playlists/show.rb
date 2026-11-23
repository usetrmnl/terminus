# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      # The show action.
      class Show < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.playlist",
          item_repository: "repositories.playlist_item"
        ]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view, **view_settings(request, parameters)
        end

        private

        def view_settings request, parameters
          playlist = repository.find parameters[:id]

          {
            playlist:,
            items: item_repository.where(playlist_id: playlist.id),
            layout: htmx_layout.call(request)
          }
        end
      end
    end
  end
end
