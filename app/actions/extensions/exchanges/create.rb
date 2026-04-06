# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The create action.
        class Create < Action
          include Deps[
            :htmx,
            extension_repository: "repositories.extension",
            repository: "repositories.extension_exchange"
          ]

          contract Contracts::Extensions::Exchanges::Create

          def handle request, response
            parameters = request.params

            if parameters.valid?
              save parameters, response
            else
              error parameters, response
            end
          end

          private

          def save parameters, response
            extension_id, exchange = parameters.to_h.values_at :extension_id, :exchange
            repository.create(extension_id:, **exchange)

            response.redirect_to routes.path(
              :extension_exchanges,
              extension_id: parameters[:extension_id]
            )
          end

          def error parameters, response
            extension_id, fields = parameters.to_h.values_at :extension_id, :exchange

            response.render view,
                            extension: extension_repository.find(extension_id),
                            fields:,
                            errors: parameters.errors[:exchange]
          end
        end
      end
    end
  end
end
