# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Jobs::Booter, :db do
  using Refinements::Array
  using Refinements::Pathname

  subject(:booter) { described_class.new schedule: }

  let(:schedule) { instance_spy Terminus::Aspects::Jobs::Schedule }

  include_context "with application dependencies"

  describe "#call" do
    it "enqueues synchronizers" do
      Sidekiq::Testing.fake! do
        booter.call

        expect(Sidekiq::Job.jobs.pluck("class")).to eq(
          %w[
            Terminus::Jobs::Synchronizers::Model
            Terminus::Jobs::Synchronizers::Firmware
            Terminus::Jobs::Synchronizers::Font
            Terminus::Jobs::Synchronizers::Sensor
          ]
        )
      end
    end

    it "upserts synchronizer schedules" do
      recordings = []

      allow(schedule).to receive(:upsert) { |*positionals| recordings << positionals }
      booter.call

      expect(recordings).to match(
        [
          ["synchronizer-model", kind_of(Hash)],
          ["synchronizer-firmware", kind_of(Hash)],
          ["synchronizer-font", kind_of(Hash)],
          ["synchronizer-sensor", kind_of(Hash)]
        ]
      )
    end

    it "upserts extension schedules" do
      extension = Factory[:extension, unit: "minute", interval: 1]

      booter.call

      expect(schedule).to have_received(:upsert).with(*extension.to_schedule)
    end

    it "logs error when synchronizer can't be found" do
      path = temp_dir.join("test.yml").write "synchronizer-bogus: null"

      booter.call path

      expect(logger.reread).to match(/ERROR.+Unable to boot job: synchronizer-bogus/)
    end
  end
end
