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
    it "answers hash" do
      expect(serializer.to_h).to match(
        id: extension.id,
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
        updated_at: match_rfc_3339,
        model_ids: [],
        device_ids: []
      )
    end

    it "answers hash with model and device IDs" do
      extension_model = Factory[:extension_model, extension_id: extension.id]
      extension_device = Factory[:extension_device, extension_id: extension.id]

      expect(serializer.to_h).to match(
        id: extension.id,
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
        updated_at: match_rfc_3339,
        model_ids: [extension_model.id],
        device_ids: [extension_device.id]
      )
    end
  end
end
