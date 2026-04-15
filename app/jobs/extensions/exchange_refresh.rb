# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Extensions
      # Refreshes exchange with new responses.
      class ExchangeRefresh < Base
        include Deps[
          "aspects.extensions.exchanges.refresher",
          repository: "repositories.extension_exchange"
        ]

        sidekiq_options queue: "within_1_minute"

        def perform id
          exchange = repository.find id

          return Failure "Unable to find exchange ID: #{id}." unless exchange

          refresher.call exchange
        end
      end
    end
  end
end
