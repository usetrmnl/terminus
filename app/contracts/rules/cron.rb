# auto_register: false
# frozen_string_literal: true

module Terminus
  module Contracts
    module Rules
      Cron = lambda do
        attributes = values.fetch(:extension).slice :interval, :unit

        case attributes
          in {unit: "none"} \
             | {unit: "minute", interval: 0..59} \
             | {unit: "hour", interval: 0..23} \
             | {unit: "day", interval: 1..31} \
             | {unit: "week", interval: 0..6} \
             | {unit: "month", interval: 1..12} then next
          else
            key.failure "invalid schedule for #{attributes[:unit]} #{attributes[:interval]}."
        end
      end
    end
  end
end
