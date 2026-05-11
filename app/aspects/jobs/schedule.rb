# frozen_string_literal: true

require "core"
require "refinements/hash"

module Terminus
  module Aspects
    module Jobs
      # Manages job schedules.
      class Schedule
        include Deps[:sidekiq]

        using Refinements::Hash

        def upsert name, configuration = Dry::EMPTY_HASH, old_name: nil
          return if identical? name, configuration

          if configuration.empty?
            delete name
          else
            delete old_name if old_name && old_name != name
            sidekiq.set_schedule name, configuration
          end
        end

        def delete(name) = sidekiq.remove_schedule name

        private

        def identical? name, configuration
          [name, sidekiq.get_schedule(name)].hash == [name, configuration.stringify_keys].hash
        end
      end
    end
  end
end
