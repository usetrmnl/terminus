# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "refinements/array"
require "refinements/hash"

module Terminus
  module Aspects
    module Devices
      module Sensors
        # Creates or updates device sensor records based on hardware readings.
        class Synchronizer
          include Deps[
            :settings,
            :logger,
            device_relation: "relations.device",
            sensor_repository: "repositories.device_sensor"
          ]
          include Dry::Monads[:result]
          include Initable[schema: proc { Terminus::Schemas::Devices::Sensors::Upsert }]

          using Refinements::Array
          using Refinements::Hash

          def call = load.then { |data| process_devices data }

          private

          def load
            path = settings.sensors_path

            return JSON path.read if path.exist?

            logger.debug { "Sensors path not found: #{path}. Skipped." }
            Core::EMPTY_HASH
          end

          def process_devices data
            device_relation.select(:id)
                           .map { it[:id] }
                           .each { |id| process_sensors id, data }
          end

          def process_sensors device_id, data
            data.fetch("data", Core::EMPTY_ARRAY).map do |entry|
              result = schema.call entry

              if result.success?
                deduplicate device_id, result.to_h
              else
                log_error result
              end
            end
          end

          def deduplicate device_id, attributes
            if find_with device_id, attributes
              logger.debug(tags: attributes) { "Duplicate sensor detected. Skipped." }
            else
              sensor_repository.create device_id:, source: "server", **attributes
            end
          end

          def find_with device_id, attributes
            attributes.transform_value!(:created_at) { Time.at(it).utc }

            make, model, kind, created_at = attributes.values_at :make, :model, :kind, :created_at

            sensor_repository.find_by device_id:,
                                      make:,
                                      model:,
                                      kind:,
                                      created_at:,
                                      source: "device"
          end

          def log_error result
            message = result.errors
                            .to_h
                            .map { |key, value| "#{key} #{value.to_sentence}" }
                            .to_sentence delimiter: "; "

            logger.error { "Unable to validate sensor: #{message}." }
          end
        end
      end
    end
  end
end
