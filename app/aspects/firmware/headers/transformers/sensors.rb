# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Firmware
      module Headers
        module Transformers
          # Transforms sensors header into an array of records.
          class Sensors
            include Initable[
              key: :HTTP_SENSORS,
              source: "device",
              delimiters: {line: ",", attribute: ";", pair: "="}
            ]

            include Dry::Monads[:result]

            using Refinements::Hash

            def call headers
              content = String headers[key]

              return split_lines content, headers if content.include? pair_delimiter

              Success headers.merge!(key => Core::EMPTY_ARRAY)
            end

            private

            def split_lines content, headers
              content.split(line_delimiter)
                     .map { split_attributes it }
                     .then { Success headers.merge! key => it }
            end

            def split_attributes line
              line.split(attribute_delimiter)
                  .to_h { it.split pair_delimiter }
                  .merge!(source:)
                  .symbolize_keys!
                  .transform_value!(:created_at) { Time.at it.to_i }
            end

            def line_delimiter = delimiters.fetch :line

            def attribute_delimiter = delimiters.fetch :attribute

            def pair_delimiter = delimiters.fetch :pair
          end
        end
      end
    end
  end
end
