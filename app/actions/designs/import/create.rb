# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Actions
    module Designs
      module Import
        # The create action.
        class Create < Action
          include Deps["aspects.designs.importer", "aspects.screens.upserter"]
          include Dry::Monads[:result]

          contract Contracts::Designs::Import

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            process parameters, response
          end

          private

          def process parameters, response
            flash = response.flash

            case upsert parameters
              in Success then flash[:notice] = translate ".notice"
              in Failure(message) then flash[:alert] = message
            end

            response.redirect_to routes.path(:designs)
          end

          def upsert parameters
            model_id, design = parameters.to_h.values_at :model_id, :design

            importer.call(design.dig(:attachment, :tempfile))
                    .bind do |screen_template|
                      upserter.call(model_id:, **screen_template.screen_attributes)
                    end
          end
        end
      end
    end
  end
end
