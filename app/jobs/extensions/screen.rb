# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Extensions
      # Creates screen for extension and model or device ID.
      class Screen < Base
        include Deps[
          :i18n,
          "aspects.extensions.screen_upserter",
          repository: "repositories.extension"
        ]

        sidekiq_options queue: "within_1_minute"

        def perform id, model_id = nil, device_id = nil
          extension = repository.find id
          ids = {extension_id: id, model_id:, device_id:}

          if extension
            screen_upserter.call(extension, model_id:, device_id:)
            log_info ids
          else
            log_error ids
          end
        end

        private

        def log_info tags
          logger.info { {tags:, message: i18n.translate("jobs.extensions.screen.info")} }
        end

        def log_error tags
          logger.error { {tags:, message: i18n.translate("jobs.extensions.screen.error")} }
        end
      end
    end
  end
end
