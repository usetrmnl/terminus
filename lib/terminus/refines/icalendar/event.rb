# frozen_string_literal: true

require "core"
require "icalendar"

module Terminus
  module Refines
    module Icalendar
      # Modifies and enhances default iCalendar event behavior.
      module Event
        refine ::Icalendar::Event do
          using Alarm

          def to_h
            {
              alarm: alarm.to_h,
              attachments: attach.map(&:to_s),
              attendees: attendee.map(&:to_s),
              categories: categories.map(&:to_s),
              classification: ip_class.to_s,
              color: color.to_s,
              comments: comment.map(&:to_s),
              contacts: contact.map(&:to_s),
              created_at: Icalendar.rfc_3339(created),
              description: description.to_s,
              duration: duration.to_h,
              end_at: Icalendar.rfc_3339(dtend),
              exceptions: Icalendar.map_3339(exdate),
              geocoordinates: coordinates(geo),
              images: image.map(&:to_s),
              location: location.to_s,
              name: ical_name,
              organizer: organizer.to_s,
              priority: priority.to_i,
              recurrence_id: Icalendar.rfc_3339(recurrence_id),
              recurrence_rule: rrule.map(&:to_h),
              recurrences: Icalendar.map_3339(rdate),
              related_to:,
              request_status: request_status.map(&:to_s),
              resources: resources.map(&:to_s),
              sequence: sequence.to_i,
              start_at: Icalendar.rfc_3339(dtstart),
              status: status.to_s,
              summary: summary.to_s,
              synced_at: Icalendar.rfc_3339(dtstamp),
              time_transparency: transp.to_s,
              uid: uid.to_s,
              updated_at: Icalendar.rfc_3339(last_modified),
              url: url.to_s
            }
          end

          private

          def coordinates(value) = value ? value.map(&:to_f) : Core::EMPTY_ARRAY
        end
      end
    end
  end
end
