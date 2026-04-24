# frozen_string_literal: true

require "core"
require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Firmware
      # Transforms a raw firmware log into attributes fit for creating a device log record.
      class LogTransformer
        include Initable[key_map: {id: :external_id}.freeze]

        using Refinements::Hash

        def call payload
          payload.fetch(:logs, Core::EMPTY_HASH).map do |item|
            item.transform_keys!(key_map).transform_value!(:created_at) { Time.at it }
          end
        end
      end
    end
  end
end
