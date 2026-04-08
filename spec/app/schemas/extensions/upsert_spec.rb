# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Schemas::Extensions::Upsert do
  subject(:contract) { described_class }

  describe "#call" do
    let :attributes do
      {
        name: "test",
        label: "Test",
        description: "A test.",
        kind: "pull",
        tags: "one two three",
        body: %({"test": "example"}),
        template: "A full test.",
        fields: %([{"name": "one", "label": "One"}, {"name": "two", "label": "Two"}]),
        data: %({"label": "Test"}),
        interval: 1,
        unit: "day",
        days: %w[monday friday],
        last_day_of_month: "on",
        start_at: "2025-01-01T00:00:00"
      }
    end

    it "answers success when all attributes are valid" do
      expect(contract.call(attributes).to_monad).to be_success
    end

    it "answers tags array" do
      expect(contract.call(attributes).to_h).to include(tags: %w[one two three])
    end

    it "answers body hash" do
      expect(contract.call(attributes).to_h).to include(body: {"test" => "example"})
    end

    it "answers fields array" do
      expect(contract.call(attributes).to_h).to include(
        fields: [
          {"label" => "One", "name" => "one"},
          {"label" => "Two", "name" => "two"}
        ]
      )
    end

    it "answers data hash" do
      expect(contract.call(attributes).to_h).to include(data: {"label" => "Test"})
    end

    it "answers true when last day of month is truthy" do
      expect(contract.call(attributes).to_h).to include(last_day_of_month: true)
    end

    it "answers false when last day of month key is missing" do
      attributes.delete :last_day_of_month
      expect(contract.call(attributes).to_h).to include(last_day_of_month: false)
    end
  end
end
