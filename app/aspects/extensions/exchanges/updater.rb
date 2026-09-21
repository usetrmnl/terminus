# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Exchanges
        # Updates an existing exchange.
        class Updater
          include Deps["aspects.jobs.schedule", repository: "repositories.extension_exchange"]
          include Initable[job: Terminus::Jobs::Extensions::ExchangeRefresh]
          include Dry::Monads[:result]

          def call attributes, validator:
            validator.call(attributes).to_monad.bind { update it.to_h }
          end

          private

          def update attributes
            extension_id, id = attributes.values_at :extension_id, :id
            exchange = repository.find_by(extension_id:, id:)

            unless exchange
              return Failure "Unable to find exchange by extension ID (#{extension_id}) " \
                             "or ID (#{id})."
            end

            job.perform_async id
            Success repository.update(id, **attributes[:exchange])
          end
        end
      end
    end
  end
end
