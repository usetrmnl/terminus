# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes TRMNL Framework fonts for local use.
      class Font < Base
        include Deps[:settings, "aspects.fonts.synchronizer"]

        sidekiq_options queue: "within_1_minute"

        def perform
          return synchronizer.call if settings.font_synchronizer

          logger.info { "Font synchronization is disabled." }
        end
      end
    end
  end
end
