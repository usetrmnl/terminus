# frozen_string_literal: true

require "dry/core"
require "refinements/time"

module Terminus
  module Structs
    # The extension struct.
    class Extension < DB::Struct
      using Refinements::Time

      # rubocop:disable Metrics/MethodLength
      def export_attributes
        {
          name:,
          label:,
          description:,
          mode:,
          kind:,
          body:,
          fields:,
          template:,
          data:,
          interval:,
          unit:,
          days:,
          last_day_of_month:,
          start_at: start_at.rfc_3339
        }
      end
      # rubocop:enable Metrics/MethodLength

      def liquid_attributes
        all_fields = Array fields

        values = all_fields.each.with_object({}) do |item, all|
          key, value = item.values_at "keyname", "default"
          all[key] = value
        end

        {"label" => label, "data" => data, "fields" => all_fields, "values" => values}
      end

      def screen_label = "Extension #{label}"

      def screen_name = "extension-#{name}"

      def screen_attributes = {label: screen_label, name: screen_name, mode:}

      def to_cron(croner: Aspects::Croner) = croner.call interval, unit, time: start_at

      def to_schedule
        [
          screen_name,
          {
            cron: to_cron,
            class: Terminus::Jobs::Batches::Extension,
            args: [id],
            description: "The #{label} extension update schedule."
          }
        ]
      end
    end
  end
end
