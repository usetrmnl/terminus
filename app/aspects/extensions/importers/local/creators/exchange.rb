# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Local
          module Creators
            # Creates exchange.
            class Exchange
              include Deps[
                "aspects.errors.detailer",
                :i18n,
                :logger,
                repository: "repositories.extension_exchange"
              ]
              include Initable[job: Terminus::Jobs::Extensions::ExchangeRefresh]

              def initialize(schema: Schemas::Exchange, **)
                @schema = schema
                super(**)
              end

              def call attributes
                schema.call(attributes)
                      .to_monad
                      .alt_map { detailer.call it, "Exchange " }
                      .fmap { create it.to_h }
              end

              private

              attr_reader :schema

              def create attributes
                repository.create(attributes).tap do |exchange|
                  log exchange, attributes
                  job.perform_async exchange.id
                end
              end

              def log exchange, attributes
                logger.debug do
                  message = i18n.translate(
                    "aspects.extensions.importers.local.creators.exchange.imported"
                  )

                  {
                    tags: [{extension_id: attributes[:extension_id], exchange_id: exchange.id}],
                    message:
                  }
                end
              end
            end
          end
        end
      end
    end
  end
end
