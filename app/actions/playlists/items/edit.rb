# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The edit action.
        class Edit < Action
          include Deps[
            repository: "repositories.playlist_item",
            screen_repository: "repositories.screen"
          ]

          params do
            required(:playlist_id).filled :integer
            required(:id).filled :integer
          end

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            item = repository.find_by playlist_id: parameters[:playlist_id], id: parameters[:id]

            response.render view,
                            screens: screen_repository.all,
                            item:,
                            screen_selection: screen_selection(item),
                            layout: false
          end

          private

          def screen_selection item
            screen_repository.find(item.screen_id).then { it.label if it }
          end
        end
      end
    end
  end
end
