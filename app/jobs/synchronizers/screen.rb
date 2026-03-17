# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes TRMNL proxied device screen updates.
      class Screen < Base
        include Deps[
          :settings,
          :trmnl_api,
          :logger,
          "aspects.screens.synchronizer",
          repository: "repositories.device"
        ]

        sidekiq_options queue: "within_1_minute"

        def perform
          return process_devices if settings.screen_synchronizer

          logger.info { "Screen polling disabled." }
        end

        private

        def process_devices = repository.all.select(&:proxy).each { |device| sync device }

        def sync device
          trmnl_api.display(token: device.api_key).bind { |record| synchronizer.call record }
        end
      end
    end
  end
end
