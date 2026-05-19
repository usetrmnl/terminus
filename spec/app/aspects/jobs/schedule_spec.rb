# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Jobs::Schedule do
  subject(:schedule) { described_class.new }

  let :extension do
    Factory.structs[:extension, id: 1, label: "Test", name: "test", unit: "minute"]
  end

  let(:sidekiq) { Hanami.app[:sidekiq] }

  describe "#upsert" do
    it "creates schedule" do
      schedule.upsert(*extension.to_schedule)

      expect(sidekiq.get_all_schedules).to eq(
        "extension-test" => {
          "cron" => "*/1 * * * * UTC",
          "class" => "Terminus::Jobs::Batches::Extension",
          "args" => [1],
          "description" => "The Test extension update schedule."
        }
      )
    end

    it "updates existing schedule" do
      schedule.upsert(*extension.to_schedule)

      schedule.upsert(
        "extension-test",
        {
          cron: "* * * * *",
          class: "Terminus::Jobs::Batches::Extension",
          args: [1],
          description: "The Test extension update schedule."
        }
      )

      expect(sidekiq.get_all_schedules).to eq(
        "extension-test" => {
          "cron" => "* * * * *",
          "class" => "Terminus::Jobs::Batches::Extension",
          "args" => [1],
          "description" => "The Test extension update schedule."
        }
      )
    end

    it "doesn't update when existing schedule is identical" do
      schedule.upsert(*extension.to_schedule)
      schedule.upsert(*extension.to_schedule)

      expect(sidekiq.get_all_schedules.keys).to contain_exactly("extension-test")
    end

    it "updates schedule name and removes old schedule" do
      schedule.upsert(*extension.to_schedule)

      schedule.upsert(
        "extension-two",
        {
          cron: "",
          class: "Terminus::Jobs::Batches::Extension",
          args: [1],
          description: "The Test extension update schedule."
        },
        old_name: "extension-test"
      )

      expect(sidekiq.get_all_schedules).to eq(
        "extension-two" => {
          "cron" => "",
          "class" => "Terminus::Jobs::Batches::Extension",
          "args" => [1],
          "description" => "The Test extension update schedule."
        }
      )
    end

    it "removes schedule when configuration is empty" do
      schedule.upsert(*extension.to_schedule)
      schedule.upsert(extension.screen_name, {})

      expect(sidekiq.get_all_schedules).to eq({})
    end
  end

  describe "#delete" do
    it "removes schedule" do
      schedule.upsert(*extension.to_schedule)
      schedule.delete extension.screen_name

      expect(sidekiq.get_all_schedules).to eq({})
    end
  end
end
