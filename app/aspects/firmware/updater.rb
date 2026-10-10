# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Firmware
      # Updates existing firmware with attachment and associations.
      class Updater
        include Deps[repository: "repositories.firmware"]

        def call attributes, io, validator:
          validator.call(attributes).to_monad.fmap { uppdate it.to_h, io }
        end

        private

        def uppdate data, io
          id, model_ids, attributes = data.values_at :id, :model_ids, :firmware

          record = repository.update_with_models id, attributes, model_ids
          repository.replace_attachment record, record.version, io
        end
      end
    end
  end
end
