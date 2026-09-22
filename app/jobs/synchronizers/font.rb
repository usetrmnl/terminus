# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes TRMNL Framework fonts for local use.
      class Font < Base
        include Deps[:settings, :i18n, "aspects.fonts.synchronizer"]

        sidekiq_options queue: "within_1_minute"

        def perform
          return synchronizer.call if settings.font_synchronizer

          logger.warn { i18n.translate "jobs.synchronizers.font.warning" }
        end
      end
    end
  end
end
