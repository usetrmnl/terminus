# frozen_string_literal: true

module Terminus
  module Refines
    # A collection of helpers methods for use in refinements.
    module Icalendar
      def self.rfc_3339(at) = (at.to_datetime.rfc3339 if at)

      def self.map_3339(collection) = collection.map { rfc_3339 it }
    end
  end
end
