# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Extensions
      # Creates a new extension with associations and job schedule.
      class Creator
        include Deps["aspects.jobs.schedule", repository: "repositories.extension"]

        def call attributes, validator:
          validator.call(attributes).to_monad.fmap { create it.to_h }
        end

        private

        def create attributes
          extension = repository.create attributes.fetch(:extension)

          associate_models extension, Array(attributes[:model_ids])
          associate_devices extension, Array(attributes[:device_ids])
          schedule.upsert(*extension.to_schedule)

          extension
        end

        def associate_models extension, model_ids
          repository.update_with_models extension.id, Core::EMPTY_HASH, model_ids
        end

        def associate_devices extension, device_ids
          repository.update_with_devices extension.id, Core::EMPTY_HASH, device_ids
        end
      end
    end
  end
end
