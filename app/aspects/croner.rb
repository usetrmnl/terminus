# auto_register: false
# frozen_string_literal: true

require "core"
require "functionable"

module Terminus
  module Aspects
    # Parses values into cron format.
    module Croner
      extend Functionable

      def call interval = nil, unit = "minute", time: Time.utc(2025, 1, 1, 0, 0, 0)
        case unit
          when "minute" then for_minute interval, time
          when "hour" then for_hour interval, time
          when "day" then for_day interval, time
          when "week" then for_week interval, time
          when "month" then for_month interval, time
          when "none" then Core::EMPTY_STRING
          else fail ArgumentError, "Unknown unit: #{unit.inspect}."
        end
      end

      def for_minute interval, time
        zone = time.zone
        interval ? "*/#{interval} * * * * #{zone}" : "* * * * * #{zone}"
      end

      def for_hour interval, time
        _, minute, *, zone = time.to_a

        case [interval, time]
          in Integer, Time then "#{minute} */#{interval} * * * #{zone}"
          else "#{minute} * * * * #{zone}"
        end
      end

      def for_day interval, time
        _, minute, hour, *, zone = time.to_a

        case [interval, time]
          in Integer, Time then "#{minute} #{hour} */#{interval} * * #{zone}"
          in Array, Time then %(#{minute} #{hour} * * #{interval.join ","} #{zone})
          else "#{minute} #{hour} * * * #{zone}"
        end
      end

      def for_week interval, time
        _, minute, hour, *, zone = time.to_a

        case interval
          in Integer then "#{minute} #{hour} * * #{interval} #{zone}"
          else "#{minute} #{hour} * * 0 #{zone}"
        end
      end

      def for_month interval, time
        _, minute, hour, *, zone = time.to_a

        case [interval, time]
          in Integer, Time then "#{minute} #{hour} * */#{interval} * #{zone}"
          in Array, Time then %(#{minute} 0 #{interval.join ","} * * #{zone})
          else "#{minute} #{hour} 1 * * #{zone}"
        end
      end

      conceal %i[for_minute for_hour for_day for_week for_month]
    end
  end
end
