# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Firmware
      # Creates a new firmware with attachment and associations.
      class Creator
        include Deps[repository: "repositories.firmware"]

        def call attributes, io, validator:
          validator.call(attributes).to_monad.fmap { create it.to_h, io }
        end

        private

        def create attributes, io
          firmware = repository.create attributes.fetch(:firmware)

          associate_models firmware, Array(attributes[:model_ids])
          repository.add_attachment firmware, io
        end

        def associate_models extension, model_ids
          repository.update_with_models extension.id, Core::EMPTY_HASH, model_ids
        end
      end
    end
  end
end
