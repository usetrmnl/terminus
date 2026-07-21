# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Extensions
      # Creates screen for extension and model or device ID.
      class Screen < Base
        include Deps["aspects.extensions.screen_upserter", repository: "repositories.extension"]

        sidekiq_options queue: "within_1_minute"

        def perform id, model_id = nil, device_id = nil
          extension = repository.find id

          if extension
            screen_upserter.call(extension, model_id:, device_id:)
            log_info id
          else
            log_error id
          end
        end

        private

        def log_info(id) = logger.info { "Enqueued screen upsert for extension ID: #{id}." }

        def log_error(id) = logger.error { "Unable to find by extension ID: #{id}." }
      end
    end
  end
end
