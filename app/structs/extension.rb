# frozen_string_literal: true

require "dry/core"

module Terminus
  module Structs
    # The extension struct.
    class Extension < DB::Struct
      WEEK = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

      def liquid_attributes
        all_fields = Array fields

        values = all_fields.each.with_object({}) do |item, all|
          key, value = item.values_at "keyname", "default"
          all[key] = Hash(data).dig("values", key) || value
        end

        {"label" => label, "fields" => all_fields, "values" => values, "data" => data}
      end

      def screen_label = "Extension #{label}"

      def screen_name = "extension-#{name}"

      def screen_attributes = {label: screen_label, name: screen_name, mode:}

      def to_cron croner: Aspects::Croner, week: WEEK
        case self
          in unit: "week" then croner.call days.map { week.index it }, unit, time: start_at
          in unit: "month", last_day_of_month: true
            croner.call "#{interval}L", unit, time: start_at
          else croner.call interval, unit, time: start_at
        end
      end

      def to_schedule
        return [screen_name, Core::EMPTY_HASH] if unit == "none"

        [
          screen_name,
          {
            cron: to_cron,
            class: Terminus::Jobs::Batches::Extension.name,
            args: [id],
            description: "The #{label} extension update schedule."
          }
        ]
      end
    end
  end
end
