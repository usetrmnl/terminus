# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes TRMNL models for local use.
      class Model < Base
        include Deps[
          :settings,
          :logger,
          palette: "aspects.palettes.synchronizer",
          model: "aspects.models.synchronizer"
        ]

        sidekiq_options queue: "within_1_minute"

        def perform
          if settings.model_synchronizer
            palette.call.bind { model.call }
          else
            logger.info { "Model synchronization is disabled." }
          end
        end
      end
    end
  end
end
