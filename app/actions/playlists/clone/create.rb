# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Clone
        # The create action.
        class Create < Action
          include Deps["aspects.playlists.cloner", repository: "repositories.playlist"]

          params do
            required(:playlist_id).filled :integer

            required(:playlist).hash do
              required(:label).filled :string
              required(:name).filled :string
              required(:mode).filled :string
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              clone parameters, response
            else
              render_form_error parameters, parameters.errors[:playlist], response
            end
          end

          private

          def clone parameters, response
            case cloner.call parameters[:playlist_id], **parameters[:playlist]
              in Success then response.redirect_to routes.path(:playlists)
              in Failure(errors) then render_form_error parameters, errors, response
            end
          end

          def render_form_error parameters, errors, response
            id, fields = parameters.to_h.values_at :playlist_id, :playlist
            response.render view, playlist: repository.find(id), fields:, errors:
          end
        end
      end
    end
  end
end
