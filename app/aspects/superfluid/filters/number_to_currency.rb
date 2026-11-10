# frozen_string_literal: true

module Terminus
  module Aspects
    module Superfluid
      module Filters
        # Renders value as currency.
        class NumberToCurrency
          def initialize caster = NumberWithDelimiter.new
            @caster = caster
          end

          def call number, unit = "$", delimiter = ",", separator = ".", precision = 2
            result = caster.call number, delimiter, separator
            dollars, cents = result.split separator

            if precision <= 0
              "#{unit}#{dollars}"
            else
              cents = cents.to_s[0..(precision - 1)].ljust precision, "0"
              "#{unit}#{dollars}#{separator}#{cents}"
            end
          end

          private

          attr_reader :caster
        end
      end
    end
  end
end
