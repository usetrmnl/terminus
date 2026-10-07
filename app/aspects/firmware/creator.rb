# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Firmware
      # Creates new firmware with attachment and associations.
      class Creator
        include Deps[repository: "repositories.firmware"]

        def call attributes, io, validator:
          validator.call(attributes).to_monad.fmap { create it.to_h, io }
        end

        private

        def create attributes, io
          firmware = repository.create attributes.fetch(:firmware)

          repository.update_with_models firmware.id, Core::EMPTY_HASH, attributes[:model_ids]
          repository.replace_attachment firmware, firmware.version, io
        end
      end
    end
  end
end
