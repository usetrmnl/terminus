# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Screens
        # The patch action.
        # :reek:DataClump
        class Patch < Base
          include Deps["aspects.screens.upserter", repository: "repositories.screen"]
          include Initable[serializer: Serializers::Screen]

          using Refines::Actions::Response

          params do
            required(:id).filled(:integer)

            required(:screen).filled(:hash) do
              optional(:model_id).filled :integer
              optional(:label).filled :string
              optional(:name).filled :string
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
            result = find(parameters).bind { |record| update record, parameters }

            case result
              in Success(screen)
                response.body = {data: serializer.new(screen).to_h}.to_json
              else unprocessable_content_for_creation result, response
            end
          end

          def find parameters
            id = parameters[:id]
            record = repository.find id

            record ? Success(record) : Failure("Unable to find screen: #{id}.")
          end

          def update record, parameters
            upserter.call(**record.to_h.slice(:model_id, :name, :label), **parameters[:screen])
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
