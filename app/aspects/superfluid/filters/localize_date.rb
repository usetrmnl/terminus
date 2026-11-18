# frozen_string_literal: true

require "initable"
require "refinements/string"

module Terminus
  module Aspects
    module Superfluid
      module Filters
        # Renders locale date.
        class LocalizeDate
          include Deps[:i18n]
          include Initable[time_pattern: /\A[0-9]+\z/]

          using Refinements::String

          def call value, format, locale = "en"
            string = value.to_s

            return value if string.blank?

            time = cast string
            format = format.to_sym unless format.include? "%"

            i18n.localize time, format:, locale:
          end

          private

          def cast string
            case string
              when "now", "today" then Time.now
              when time_pattern then Time.at(string.to_i)
              else Time.parse string
            end
          end
        end
      end
    end
  end
end
