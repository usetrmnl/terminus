# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The update action.
        class Update < Action
          include Deps[
            "aspects.extensions.exchanges.updater",
            "aspects.errors.detailer",
            validator: "contracts.extensions.exchanges.update",
            repository: "repositories.extension_exchange",
            extension_repository: "repositories.extension"
          ]

          def handle request, response
            case updater.call(request.params.to_h, validator:)
              in Success(exchange) then success exchange, response
              in Failure(String) then halt :unprocessable_content
              in Failure(result) then failure result, response
            end
          end

          private

          def success exchange, response
            response.redirect_to routes.path(
              :extension_exchanges,
              extension_id: exchange.extension_id
            )
          end

          def failure result, response
            exchange = repository.find result[:id]
            errors = result.errors[:exchange]
            response.flash.now[:alert] = detailer.call errors, "Exchange "

            response.render view,
                            extension: extension_repository.find(exchange.extension_id),
                            exchange:,
                            fields: result[:exchange],
                            errors:
          end
        end
      end
    end
  end
end
