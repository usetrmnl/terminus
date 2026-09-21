# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The create action.
        class Create < Action
          include Deps[
            "aspects.extensions.exchanges.creator",
            "aspects.errors.detailer",
            validator: "contracts.extensions.exchanges.create",
            extension_repository: "repositories.extension"
          ]

          def handle request, response
            case creator.call(request.params.to_h, validator:)
              in Success then success request, response
              in Failure(result) then failure result, response
            end
          end

          private

          def success request, response
            response.redirect_to routes.path(
              :extension_exchanges,
              extension_id: request.params[:extension_id]
            )
          end

          def failure result, response
            extension_id, fields = result.to_h.values_at :extension_id, :exchange
            errors = result.errors[:exchange]

            response.flash.now[:alert] = detailer.call errors, "Exchange "
            response.render view,
                            extension: extension_repository.find(extension_id),
                            fields:,
                            errors:
          end
        end
      end
    end
  end
end
