# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The create action.
        # rubocop:todo-next I18n/RailsI18n/DecorateString
        class Create < Base
          include Deps[repository: "repositories.extension"]
          include Initable[serializer: Serializers::Extension]

          using Refines::Actions::Response

          # TODO: Switch to schema
          # contract Contracts::Extensions::Create

          params do
            required(:extension).filled(:hash) do
              required(:name).filled :string
              required(:label).filled :string
              required(:description).maybe :string
              required(:mode).filled :string
              required(:kind).filled :string
              required(:tags).array :string
              required(:static_body).maybe :hash
              required(:template).maybe :string
              required(:fields).array :hash
              required(:data).maybe :hash
              required(:interval).filled :integer
              required(:unit).filled :string
              required(:days).array :string
              required(:last_day_of_month).filled :bool
              required(:start_at).filled :date_time
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              extension = repository.create parameters[:extension]
              response.with body: {data: serializer.new(extension).to_h}.to_json
            else
              unprocessable_content parameters.errors.to_h, response
            end
          end

          private

          def unprocessable_content errors, response
            response.with_details problem[
              type: "/problem_details#extension_payload",
              status: :unprocessable_content,
              detail: "Validation failed.",
              instance: "/api/extensions",
              extensions: {errors:}
            ]
          end
        end
      end
    end
  end
end
