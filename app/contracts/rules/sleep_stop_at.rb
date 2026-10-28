# auto_register: false
# frozen_string_literal: true

module Terminus
  module Contracts
    module Rules
      SleepStopAt = lambda do
        root = path.root
        start_at = if root.start_with? "sleep"
                     values[:sleep_start_at]
                   else
                     values.dig root, :sleep_start_at
                   end

        if value && start_at.nil? then key.failure "must have corresponding start time"
        elsif value.nil? && start_at then key.failure "must be filled"
        else next
        end
      end
    end
  end
end
