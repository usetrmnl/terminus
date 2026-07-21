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

          if exchange
            refresher.call exchange
            log_info id
          else
            log_error id
          end
        end

        private

        def log_info(id) = logger.info { "Enqueued refresh for exchange: #{id}." }

        def log_error(id) = logger.error { "Unable to find exchange ID: #{id}." }
      end
    end
  end
end
