# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The update action.
        class Update < Action
          include Deps[
            extension_repository: "repositories.extension",
            repository: "repositories.extension_exchange"
          ]

          contract Contracts::Extensions::Exchanges::Update

          def handle request, response
            parameters = request.params
            extension_id, id = parameters.to_h.values_at :extension_id, :id
            exchange = repository.find_by(extension_id:, id:)

            if parameters.valid?
              save exchange, parameters, response
            else
              error exchange, parameters, response
            end
          end

          private

          def save exchange, parameters, response
            repository.update exchange.id, **parameters[:exchange]

            response.redirect_to routes.path(
              :extension_exchanges,
              extension_id: exchange.extension_id
            )
          end

          def error exchange, parameters, response
            response.render view,
                            extension: extension_repository.find(exchange.extension_id),
                            exchange:,
                            fields: parameters[:exchange],
                            errors: parameters.errors[:exchange]
          end
        end
      end
    end
  end
end
