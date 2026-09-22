# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Playlists
        # The patch action.
        class Patch < Base
          include Deps[repository: "repositories.playlist"]
          include Initable[serializer: Serializers::Playlist]

          using Refines::Actions::Response

          params do
            required(:id).filled :integer

            required(:playlist).filled(:hash) do
              optional(:current_item_id).filled :integer
              required(:name).filled :string
              required(:label).filled :string
              optional(:mode).filled :string
              optional(:items).maybe(:array).each(:hash) { required(:screen_id).filled :integer }
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              playlist = update parameters
              response.body = {data: serializer.new(playlist).to_h}.to_json
            else
              unprocessable_content parameters, response
            end
          end

          private

          def update parameters
            id, attributes = parameters.to_h.values_at :id, :playlist
            repository.update_with_items id, attributes, attributes[:items]
            repository.with_items.by_pk(id).one
          end

          def unprocessable_content parameters, response
            response.with_details problem[
              type: "/problem_details#playlist_payload",
              status: :unprocessable_content,
              detail: translate("api.shared.errors.validation"),
              instance: "/api/playlists",
              extensions: {errors: parameters.errors.to_h}
            ]
          end
        end
      end
    end
  end
end
