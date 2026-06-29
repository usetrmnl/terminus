# frozen_string_literal: true

require "pipeable"

module Terminus
  module Aspects
    module Firmware
      module Headers
        # Parses firmware HTTP headers into records.
        class Parser
          include Deps[
            :logger,
            model_name_transformer: "aspects.firmware.headers.transformers.model_name",
            sensors_transformer: "aspects.firmware.headers.transformers.sensors"
          ]
          include Pipeable

          def initialize(schema: Schemas::Firmware::Header, model: Model, **)
            @schema = schema
            @model = model
            super(**)
          end

          def call headers
            logger.debug { {tags: tags(headers), message: "Processing device request headers."} }

            pipe headers,
                 validate(schema, as: :to_h),
                 use(model_name_transformer),
                 use(sensors_transformer),
                 to(model, :for)
          end

          private

          attr_reader :schema, :model

          def tags headers
            headers.select { |key, _| key.start_with? "HTTP_" }
                   .then { [it] }
          end
        end
      end
    end
  end
end
