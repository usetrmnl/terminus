# frozen_string_literal: true

require "icalendar"

module Terminus
  module Refines
    module Icalendar
      # Modifies and enhances default iCalendar timezone behavior.
      module Timezone
        refine ::Icalendar::Timezone do
          def to_h
            {
              id: tzid.to_s,
              url: tzurl.to_s,
              updated_at: Icalendar.rfc_3339(last_modified)
            }
          end
        end
      end
    end
  end
end
