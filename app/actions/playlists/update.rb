# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      # The update action.
      class Update < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.playlist",
          item_repository: "repositories.playlist_item",
          show_view: "views.playlists.show"
        ]

        params do
          required(:id).filled :integer

          required(:playlist).hash do
            required(:label).filled :string
            required(:name).filled :string
            required(:mode).filled :string
          end
        end

        protected

        def handle request, response
          parameters = request.params
          playlist = repository.find parameters[:id]

          halt :unprocessable_content unless playlist

          if parameters.valid?
            render_view request, response
          else
            render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params
          playlist = repository.find parameters[:id]

          response.render view,
                          playlist:,
                          fields: parameters[:playlist],
                          errors: parameters.errors[:playlist],
                          layout: htmx_layout.call(request)
        end

        private

        def render_view request, response
          parameters = request.params
          id = parameters[:id]
          repository.update id, **parameters[:playlist]

          response.render show_view,
                          playlist: repository.find(id),
                          items: item_repository.where(playlist_id: id),
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
