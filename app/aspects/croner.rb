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
        return "* * * * *" unless interval

        offset = time.min % interval
        "#{offset.step(59, interval).to_a.join(",")} * * * *"
      end

      def for_hour interval, time
        _, minute, * = time.to_a

        case [interval, time]
          in Integer, Time then "#{minute} */#{interval} * * *"
          else "#{minute} * * * *"
        end
      end

      def for_day interval, time
        _, minute, hour, * = time.to_a

        case [interval, time]
          in Integer, Time then "#{minute} #{hour} */#{interval} * *"
          else "#{minute} #{hour} * * *"
        end
      end

      def for_week interval, time
        _, minute, hour, * = time.to_a

        case interval
          in Integer then "#{minute} #{hour} * * #{interval}"
          in Array then %(#{minute} #{hour} * * #{interval.join ","})
          else "#{minute} #{hour} * * 0"
        end
      end

      def for_month interval, time
        _, minute, hour, * = time.to_a

        case [interval, time]
          in Integer, Time then "#{minute} #{hour} * */#{interval} *"
          in String, Time
            part, directive = interval.scan(/\d+|\D+/)
            %(#{minute} #{hour} #{directive} */#{part} *)
          in Array, Time then %(#{minute} 0 #{interval.join ","} * *)
          else "#{minute} #{hour} 1 * *"
        end
      end

      conceal %i[for_minute for_hour for_day for_week for_month]
    end
  end
end
