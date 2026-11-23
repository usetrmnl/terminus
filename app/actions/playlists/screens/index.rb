# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Screens
        # The index action.
        class Index < Action
          include Deps[repository: "repositories.playlist", view: "views.playlists.screens.show"]
          include Initable[slide_window: Aspects::Playlists::SlideWindow]

          params { required(:playlist_id).filled :integer }

          protected

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            window = load_window parameters
            before, current, after = window.screens

            response.render view, playlist: window.playlist, before:, current:, after:
          end

          private

          def load_window parameters
            slide_window.new repository.with_screens.by_pk(parameters[:playlist_id]).one
          end
        end
      end
    end
  end
end
