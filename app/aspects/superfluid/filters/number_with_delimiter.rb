# frozen_string_literal: true

module Terminus
  module Aspects
    module Superfluid
      module Filters
        # Renders formatted numbers.
        class NumberWithDelimiter
          PATTERN = /\A-?\d+(\.\d+)?\z/

          def initialize pattern: PATTERN
            @pattern = pattern
            @minus = "-"
            @decimal = "."
          end

          def call value, group = ",", separator = "."
            value = String value

            return value unless value.match? pattern

            integer, fractional, negative = build_parts value
            integer_with_groups = integer.reverse.scan(/\d{1,3}/).join(group).reverse
            integer_with_groups = "#{minus}#{integer_with_groups}" if negative

            fractional ? "#{integer_with_groups}#{separator}#{fractional}" : integer_with_groups
          end

          private

          attr_reader :pattern, :minus, :decimal

          def build_parts value
            integer, fractional = value.split decimal
            negative = integer.start_with? minus
            integer = integer[1..] if negative

            [integer, fractional, negative]
          end
        end
      end
    end
  end
end
