# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The update action.
        class Update < Action
          include Deps[
            :htmx_layout,
            repository: "repositories.playlist_item",
            show_view: "views.playlists.items.show"
          ]

          params do
            required(:id).filled :integer
            required(:playlist_id).filled :integer
            required(:playlist_item).hash { required(:screen_id).filled :integer }
          end

          protected

          def handle request, response
            parameters = request.params

            if parameters.valid?
              save request, response
            else
              render_errors request, response
            end
          end

          def render_errors request, response
            parameters = request.params

            response.render view,
                            playlist:,
                            fields: parameters[:playlist],
                            errors: parameters.errors[:playlist],
                            layout: htmx_layout.call(request)
          end

          private

          def save request, response
            parameters = request.params
            item = repository.find_by playlist_id: parameters[:playlist_id], id: parameters[:id]
            id = item.id
            repository.update id, **parameters[:playlist_item]

            response.render show_view, item: repository.find(id), layout: htmx_layout.call(request)
          end
        end
      end
    end
  end
end
