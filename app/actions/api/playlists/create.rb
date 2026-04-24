# frozen_string_literal: true

require "core"

module Terminus
  module Actions
    module API
      module Playlists
        # The create action.
        class Create < Base
          include Deps[
            repository: "repositories.playlist",
            item_repository: "repositories.playlist_item"
          ]

          include Initable[serializer: Serializers::Playlist]

          using Refines::Actions::Response

          params do
            required(:playlist).filled(:hash) do
              required(:name).filled :string
              required(:label).filled :string
              optional(:mode).filled :string
              optional(:items).maybe(:array).each(:hash) { required(:screen_id).filled :integer }
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              playlist = save parameters[:playlist]
              response.body = {data: serializer.new(playlist).to_h}.to_json
            else
              unprocessable_content parameters, response
            end
          end

          private

          def save attributes
            items = attributes.fetch :items, Core::EMPTY_ARRAY
            playlist = repository.create_with_items attributes, items
            repository.with_items.by_pk(playlist.id).one
          end

          def unprocessable_content parameters, response
            payload = problem[
              type: "/problem_details#playlist_payload",
              status: :unprocessable_content,
              detail: "Validation failed.",
              instance: "/api/playlists",
              extensions: {errors: parameters.errors.to_h}
            ]

            response.with body: payload.to_json, format: :problem_details, status: payload.status
          end
        end
      end
    end
  end
end
