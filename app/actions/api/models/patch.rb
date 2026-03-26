# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Models
        # The patch action.
        class Patch < Base
          include Deps[repository: "repositories.model"]
          include Initable[serializer: Serializers::Model]

          using Refines::Actions::Response

          params do
            required(:id).filled :integer

            required(:model).filled(:hash) do
              optional(:name).filled :string
              optional(:label).filled :string
              optional(:description).maybe :string
              optional(:mime_type).filled :string
              optional(:colors).filled :integer
              optional(:bit_depth).filled :integer
              optional(:rotation).filled :integer
              optional(:offset_x).filled :integer
              optional(:offset_y).filled :integer
              optional(:scale_factor).filled :float
              optional(:width).filled :integer
              optional(:height).filled :integer
              optional(:palette_names).maybe :array
              optional(:css).maybe :hash
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              model = repository.update(*parameters.to_h.values_at(:id, :model))
              response.body = {data: serializer.new(model).to_h}.to_json
            else
              unprocessable_content parameters, response
            end
          end

          private

          def unprocessable_content parameters, response
            body = problem[
              type: "/problem_details#model_payload",
              status: :unprocessable_content,
              detail: "Validation failed.",
              instance: "/api/models",
              extensions: {errors: parameters.errors.to_h}
            ]

            response.with body: body.to_json, format: :problem_details, status: 422
          end
        end
      end
    end
  end
end
