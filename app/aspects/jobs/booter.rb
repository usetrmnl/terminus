# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Jobs
      # Ensures jobs are enqueued and schedules are loaded upon server boot or reboot.
      class Booter
        include Deps[
          :logger,
          "aspects.jobs.schedule",
          extension_repository: "repositories.extension"
        ]
        include Initable[offset: 5]

        def call configuration_path = Hanami.app.root.join("config/sidekiq_scheduler.yml")
          schedule_synchronizers configuration_path
          schedule_extensions
        end

        private

        def schedule_synchronizers configuration_path
          YAML.load_file(configuration_path).each.with_index do |(name, configuration), index|
            enqueue_and_schedule name, configuration, index
          rescue NameError, TypeError
            logger.error { "Unable to boot job: #{name}." }
          end
        end

        def enqueue_and_schedule name, configuration, index
          Object.const_get(configuration["class"]).perform_in index * offset
          schedule.upsert name, configuration
        end

        def schedule_extensions = extension_repository.all.each { schedule.upsert(*it.to_schedule) }
      end
    end
  end
end
