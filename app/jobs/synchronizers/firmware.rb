# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes TRMNL Firmware for local use.
      class Firmware < Base
        include Deps[:settings, :i18n, :logger, "aspects.firmware.synchronizer"]

        sidekiq_options queue: "within_1_minute"

        def perform
          return synchronizer.call if settings.firmware_synchronizer

          logger.warn { i18n.translate "jobs.synchronizers.firmware.warning" }
        end
      end
    end
  end
end
