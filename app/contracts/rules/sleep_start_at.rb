# auto_register: false
# frozen_string_literal: true

module Terminus
  module Contracts
    module Rules
      SleepStartAt = lambda do
        root = path.root
        stop_at = if root.start_with? "sleep"
                    values[:sleep_stop_at]
                  else
                    values.dig root, :sleep_stop_at
                  end

        if value && stop_at.nil? then key.failure "must have corresponding stop time"
        elsif value.nil? && stop_at then key.failure "must be filled"
        else next
        end
      end
    end
  end
end
