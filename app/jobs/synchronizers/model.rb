# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes TRMNL models for local use.
      class Model < Base
        include Deps[:settings, :logger, "aspects.models.synchronizer"]

        sidekiq_options queue: "within_1_minute"

        def perform
          return synchronizer.call if settings.model_synchronizer

          logger.info { "Model polling disabled." }
        end
      end
    end
  end
end
