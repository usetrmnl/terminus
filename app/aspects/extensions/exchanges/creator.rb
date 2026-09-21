# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Extensions
      module Exchanges
        # Creates a new exchange.
        class Creator
          include Deps["aspects.jobs.schedule", repository: "repositories.extension_exchange"]
          include Initable[job: Terminus::Jobs::Extensions::ExchangeRefresh]

          def call attributes, validator:
            validator.call(attributes).to_monad.fmap { create it.to_h }
          end

          private

          def create attributes
            exchange = repository.create extension_id: attributes[:extension_id],
                                         **attributes[:exchange]

            job.perform_async exchange.id
            exchange
          end
        end
      end
    end
  end
end
