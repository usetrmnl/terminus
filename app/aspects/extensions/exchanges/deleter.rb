# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Exchanges
        # Deletes an existing exchange.
        class Deleter
          include Deps[repository: "repositories.extension_exchange"]
          include Dry::Monads[:result]

          def call attributes, validator:
            validator.call(attributes).to_monad.bind { delete it.to_h }
          end

          private

          def delete attributes
            extension_id, id = attributes.values_at :extension_id, :id
            exchange = repository.find_by(extension_id:, id:)

            unless exchange
              return Failure "Unable to find exchange by extension ID (#{extension_id}) " \
                             "or ID (#{id})."
            end

            repository.delete id
            Success exchange
          end
        end
      end
    end
  end
end
