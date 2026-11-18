# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      module Import
        # The create action.
        class Create < Action
          include Deps["aspects.models.importer"]
          include Dry::Monads[:result]

          params do
            required(:model).filled(:hash) { required(:attachment).filled Schemas::Attachment }
          end

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            process parameters.to_h.dig(:model, :attachment, :tempfile), response
          end

          private

          def process temp_file, response
            flash = response.flash

            case importer.call temp_file
              in Success then flash[:notice] = translate ".notice"
              in Failure(message) then flash[:alert] = message
            end

            response.redirect_to routes.path(:models)
          end
        end
      end
    end
  end
end
