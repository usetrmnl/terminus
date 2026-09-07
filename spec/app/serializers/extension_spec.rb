# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Serializers::Extension, :db do
  subject(:serializer) { described_class.new extension }

  let(:extension) { Factory[:extension, **attributes] }

  let :attributes do
    {
      id: 1,
      label: "Test",
      name: "test",
      description: "Test.",
      kind: "poll",
      mode: "text",
      tags: %w[one two],
      static_body: {a: 1},
      fields: [{name: "test"}],
      template: "<h1>{{source_1.label}}</h1>",
      data: {name: "test"},
      interval: 1,
      unit: "none",
      days: %w[monday friday],
      last_day_of_month: true,
      start_at: Time.new(2025, 1, 1, 0, 0, 0),
      created_at: Time.new(2025, 1, 1, 0, 0, 0),
      updated_at: Time.new(2025, 1, 1, 0, 0, 0)
    }
  end

  describe "#to_h" do
    it "answers hash with image attributes" do
      expect(serializer.to_h).to match(
        id: 1,
        label: "Test",
        name: "test",
        description: "Test.",
        kind: "poll",
        mode: "text",
        tags: %w[one two],
        static_body: {"a" => 1},
        fields: [{"name" => "test"}],
        template: "<h1>{{source_1.label}}</h1>",
        data: {"name" => "test"},
        interval: 1,
        unit: "none",
        days: %w[monday friday],
        last_day_of_month: true,
        start_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      )
    end
  end
end
