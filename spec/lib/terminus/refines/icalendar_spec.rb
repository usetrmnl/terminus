# frozen_string_literal: true

require "hanami_helper"
require "icalendar"

RSpec.describe Terminus::Refines::Icalendar do
  describe ".rfc_3339" do
    it "answers converted date" do
      at = Icalendar::Values::DateTime.new Date.new(2026, 10, 5)
      expect(described_class.rfc_3339(at)).to eq("2026-10-05T00:00:00+00:00")
    end

    it "answers converted time" do
      at = Icalendar::Values::DateTime.new Time.new(2026, 10, 5, 1, 2, 3, "+04:00")
      expect(described_class.rfc_3339(at)).to eq("2026-10-05T01:02:03+04:00")
    end

    it "answers converted date/time" do
      at = Icalendar::Values::DateTime.new DateTime.new(2026, 10, 5, 1, 2, 3, "+04:00")
      expect(described_class.rfc_3339(at)).to eq("2026-10-05T01:02:03+04:00")
    end
  end

  describe ".map_3339" do
    it "answers array of converted date/times" do
      collection = [
        Date.new(2026, 10, 5),
        Time.new(2026, 10, 5, 1, 2, 3, "+04:00"),
        DateTime.new(2026, 10, 5, 1, 2, 3, "+04:00")
      ]

      expect(described_class.map_3339(collection)).to eq(
        [
          "2026-10-05T00:00:00+00:00",
          "2026-10-05T01:02:03+04:00",
          "2026-10-05T01:02:03+04:00"
        ]
      )
    end
  end
end
