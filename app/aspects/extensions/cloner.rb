# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      # Clones an existing extension.
      class Cloner
        include Deps[
          "aspects.jobs.schedule",
          repository: "repositories.extension",
          exchange_repository: "repositories.extension_exchange"
        ]

        include Dry::Monads[:result]

        def call(id, **overrides)
          Success create(id, build_attributes(id, overrides))
        rescue ROM::SQL::UniqueConstraintError => error
          build_failure error.message
        end

        private

        def build_attributes id, overrides
          original = repository.find id

          {
            **original.to_h.except(:id, :created_at, :updated_at),
            label: "#{original.label} Clone",
            name: "#{original.name}_clone",
            **overrides
          }
        end

        def create id, attributes
          extension = create_with_models attributes

          add_devices extension, attributes
          add_exchanges id, extension
          add_schedule extension
          extension
        end

        def create_with_models attributes
          repository.create_with_models attributes, Array(attributes[:model_ids])
        end

        def add_devices extension, attributes
          repository.update_with_devices extension.id, {}, Array(attributes[:device_ids])
        end

        def add_exchanges original_id, extension
          exchange_repository.where(extension_id: original_id).each do |original|
            exchange_repository.create extension_id: extension.id,
                                       **original.to_h.except(
                                         :id,
                                         :extension_id,
                                         :created_at,
                                         :updated_at
                                       )
          end
        end

        def add_schedule extension
          schedule.upsert(*extension.to_schedule)
        end

        def build_failure message
          match = message.match(/Key \((?<key>[^)]+)\)/)
          Failure match[:key].to_sym => ["must be unique"]
        end
      end
    end
  end
end
