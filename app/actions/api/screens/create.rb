# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Screens
        # The create action.
        class Create < Base
          include Deps[
            "aspects.screens.upserter",
            repository: "repositories.screen",
            playlist_item_repository: "repositories.playlist_item"
          ]

          include Initable[serializer: Serializers::Screen]

          using Refines::Actions::Response

          params do
            required(:screen).filled(:hash) do
              optional(:playlist_id).filled :integer
              required(:model_id).filled :integer
              required(:label).filled :string
              required(:name).filled :string
              optional(:content).filled :string
              optional(:uri).filled :string
              optional(:preprocessed).filled :bool
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              save parameters, response
            else
              unprocessable_content_for_parameters parameters.errors.to_h, response
            end
          end

          private

          def save parameters, response
            result = find(parameters).bind { upserter.call(**parameters[:screen]) }

            case result
              in Success(screen)
                create_playlist_item parameters.dig(:screen, :playlist_id), screen
                response.body = {data: serializer.new(screen).to_h}.to_json
              else unprocessable_content_for_creation result, response
            end
          end

          def find parameters
            model_id, name = parameters[:screen].to_h.values_at :model_id, :name

            return Success() unless repository.find_by(model_id:, name:)

            Failure "Screen exists with name (#{name.inspect}) and model ID (#{model_id})."
          end

          def create_playlist_item playlist_id, screen
            return unless playlist_id

            playlist_item_repository.create_with_position playlist_id:, screen_id: screen.id
          end

          def unprocessable_content_for_parameters errors, response
            body = problem[
              type: "/problem_details#screen_payload",
              status: :unprocessable_content,
              detail: "Validation failed.",
              instance: "/api/screens",
              extensions: {errors:}
            ]

            response.with body: body.to_json, format: :problem_details, status: 422
          end

          def unprocessable_content_for_creation result, response
            body = problem[
              type: "/problem_details#screen_payload",
              status: :unprocessable_content,
              detail: result.failure,
              instance: "/api/screens"
            ]

            response.with body: body.to_json, format: :problem_details, status: 422
          end
        end
      end
    end
  end
end
