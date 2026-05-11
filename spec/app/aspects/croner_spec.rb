# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Croner do
  subject(:croner) { described_class }

  describe ".call" do
    let(:time) { Time.utc 2025, 1, 1, 5, 30, 0 }

    it "answers cron for every specific minute" do
      expect(croner.call(5, "minute")).to eq("*/5 * * * * UTC")
    end

    it "answers cron for every minute" do
      expect(croner.call(nil, "minute")).to eq("* * * * * UTC")
    end

    it "answers cron for every specific hour" do
      expect(croner.call(5, "hour")).to eq("0 */5 * * * UTC")
    end

    it "answers cron for every specific hour and minute" do
      expect(croner.call(5, "hour", time:)).to eq("30 */5 * * * UTC")
    end

    it "answers cron for every hour" do
      expect(croner.call(nil, "hour")).to eq("0 * * * * UTC")
    end

    it "answers cron for specific day" do
      expect(croner.call(5, "day")).to eq("0 0 */5 * * UTC")
    end

    it "answers cron for specific day, hour, and minute of the week" do
      expect(croner.call(5, "day", time:)).to eq("30 5 */5 * * UTC")
    end

    it "answers cron for every day" do
      expect(croner.call(nil, "day")).to eq("0 0 * * * UTC")
    end

    it "answers cron for specific day of the week" do
      expect(croner.call(4, "week")).to eq("0 0 * * 4 UTC")
    end

    it "answers cron for specific days of the week" do
      expect(croner.call([1, 3, 5], "week")).to eq("0 0 * * 1,3,5 UTC")
    end

    it "answers cron for specific days, hour, and minute of the week" do
      expect(croner.call([2, 4], "week", time:)).to eq("30 5 * * 2,4 UTC")
    end

    it "answers cron for every week" do
      expect(croner.call(nil, "week")).to eq("0 0 * * 0 UTC")
    end

    it "answers cron for every specific month" do
      expect(croner.call(5, "month")).to eq("0 0 * */5 * UTC")
    end

    it "answers cron for last day of month" do
      expect(croner.call("5L", "month")).to eq("0 0 L */5 * UTC")
    end

    it "answers cron for specific month, hour, and month" do
      expect(croner.call(5, "month", time:)).to eq("30 5 * */5 * UTC")
    end

    it "answers cron for specific days of each month" do
      expect(croner.call([1, 5, 10], "month")).to eq("0 0 1,5,10 * * UTC")
    end

    it "answers cron for specific minute and days of each month" do
      expect(croner.call([1, 5, 10], "month", time:)).to eq("30 0 1,5,10 * * UTC")
    end

    it "answers cron for every month" do
      expect(croner.call(nil, "month")).to eq("0 0 1 * * UTC")
    end

    it "answers empty string when type is none" do
      expect(croner.call(nil, "none")).to eq("")
    end

    it "fails with unknown unit" do
      expectation = proc { croner.call 1, :bogus }
      expect(&expectation).to raise_error(ArgumentError, "Unknown unit: :bogus.")
    end
  end
end
