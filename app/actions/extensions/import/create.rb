# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Actions
    module Extensions
      module Import
        # The create action.
        class Create < Action
          include Deps["aspects.extensions.importers.local.creator"]
          include Dry::Monads[:result]

          contract Contracts::Extensions::Imports::Create

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            process parameters.to_h.dig(:extension, :attachment, :tempfile), response
          end

          private

          def process temp_file, response
            flash = response.flash

            case creator.call temp_file
              in Success then flash[:notice] = "Extension imported!"
              in Failure(message) then flash[:alert] = message
            end

            response.redirect_to routes.path(:extensions)
          end
        end
      end
    end
  end
end
