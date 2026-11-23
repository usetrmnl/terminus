# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Screens
        # The show action.
        class Show < Action
          include Deps[:htmx_layout, "aspects.playlists.current_item_advancer"]
          include Initable[slide_window: Aspects::Playlists::SlideWindow]

          params do
            required(:playlist_id).filled :integer
            required(:id).filled :integer
          end

          protected

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            response.render view, **view_settings(request, advance_current_item(parameters))
          end

          private

          def view_settings request, playlist
            before, current, after = slide_window.new(playlist).screens request.params[:id]
            {playlist:, before:, current:, after:, layout: htmx_layout.call(request)}
          end

          def advance_current_item parameters
            playlist_id, screen_id = parameters.to_h.values_at :playlist_id, :id
            current_item_advancer.call playlist_id, screen_id:
          end
        end
      end
    end
  end
end
