# frozen_string_literal: true

require "icalendar"

module Terminus
  module Refines
    module Icalendar
      # Modifies and enhances default iCalendar calendar behavior.
      module Calendar
        using Event
        using Timezone

        refine ::Icalendar::Calendar do
          def to_h
            {
              categories: categories.map(&:to_s),
              color: color.to_s,
              description: description.map(&:to_s),
              events: events.map { it.to_h },
              images: image.map(&:to_s),
              ip_method: ip_method.to_s,
              name: ical_name.to_s,
              product_identifier: prodid.to_s,
              refresh_interval: refresh_interval.to_h,
              scale: calscale.to_s,
              source: source.to_s,
              timezone: timezone.to_h,
              uid: uid.to_s,
              updated_at: Icalendar.rfc_3339(last_modified),
              url: url.to_s,
              version: version.to_s
            }
          end
        end
      end
    end
  end
end
