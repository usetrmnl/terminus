# frozen_string_literal: true

require "core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      # Updates an existing extension with associations and job schedule.
      class Updater
        include Deps["aspects.jobs.schedule", repository: "repositories.extension"]
        include Dry::Monads[:result]

        def call attributes, validator:
          id = attributes[:id]
          extension = repository.find id

          return Failure "Unable to find extension ID: #{id}." unless extension

          validate(extension, attributes, validator).fmap { update id, it.to_h }
        end

        private

        def validate extension, attributes, validator
          validator.call(attributes).to_monad.alt_map { [extension, it] }
        end

        def update id, attributes
          extension = repository.update id, attributes.fetch(:extension, Core::EMPTY_HASH)
          update_ancillaries extension, attributes
        end

        def update_ancillaries extension, attributes
          update_models extension, Array(attributes[:model_ids])
          update_devices extension, Array(attributes[:device_ids])
          schedule.upsert(*extension.to_schedule, old_name: extension.screen_name)
          extension
        end

        def update_models extension, model_ids
          repository.update_with_models extension.id, Core::EMPTY_HASH, model_ids
        end

        def update_devices extension, device_ids
          repository.update_with_devices extension.id, Core::EMPTY_HASH, device_ids
        end
      end
    end
  end
end
