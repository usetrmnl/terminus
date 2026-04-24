# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::Extension do
  subject :extension do
    Factory.structs[
      :extension,
      id: 1,
      name: "test",
      label: "Test",
      interval: 5,
      unit: "minute",
      start_at: Time.utc(2025, 1, 2, 3, 4, 5)
    ]
  end

  describe "#export_attributes" do
    it "answers attributes" do
      expect(extension.export_attributes).to eq(
        name: "test",
        label: "Test",
        description: nil,
        kind: "poll",
        mode: nil,
        body: nil,
        fields: [],
        data: {},
        days: nil,
        interval: 5,
        last_day_of_month: nil,
        start_at: "2025-01-02T03:04:05+00:00",
        template: nil,
        unit: "minute"
      )
    end
  end

  describe "#liquid_attributes" do
    it "answers defaults when empty" do
      expect(extension.liquid_attributes).to eq(
        "label" => "Test",
        "data" => {},
        "fields" => [],
        "values" => {}
      )
    end

    it "answers filled attributes when filled" do
      extension = Factory.structs[
        :extension,
        label: "Test",
        data: {"id" => 123},
        fields: [
          {"keyname" => "one", "default" => 1},
          {"keyname" => "two"},
          {"keyname" => "three", "default" => 3}
        ]
      ]

      expect(extension.liquid_attributes).to eq(
        "label" => "Test",
        "data" => {"id" => 123},
        "fields" => [
          {"keyname" => "one", "default" => 1},
          {"keyname" => "two"},
          {"keyname" => "three", "default" => 3}
        ],
        "values" => {
          "one" => 1,
          "two" => nil,
          "three" => 3
        }
      )
    end
  end

  describe "#screen_name" do
    it "answers name" do
      expect(extension.screen_name).to eq("extension-test")
    end
  end

  describe "#screen_label" do
    it "answers label" do
      expect(extension.screen_label).to eq("Extension Test")
    end
  end

  describe "#screen_attributes" do
    it "answers attributes" do
      extension = Factory.structs[:extension, id: 1, name: "test", label: "Test", mode: "dither"]

      expect(extension.screen_attributes).to eq(
        label: "Extension Test",
        name: "extension-test",
        mode: "dither"
      )
    end
  end

  describe "#to_cron" do
    it "answers schedule when set" do
      expect(extension.to_cron).to eq("*/5 * * * * UTC")
    end

    it "answers empty string when there is no schedule" do
      expect(Factory.structs[:extension].to_cron).to eq("")
    end
  end

  describe "#to_schedule" do
    it "answers schedule" do
      expect(extension.to_schedule).to eq(
        [
          "extension-test",
          {
            cron: "*/5 * * * * UTC",
            class: Terminus::Jobs::Batches::Extension,
            args: [1],
            description: "The Test extension update schedule."
          }
        ]
      )
    end
  end
end
