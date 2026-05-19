# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Serializers::Screen, :db do
  subject(:serializer) { described_class.new screen }

  let(:screen) { Factory[:screen, :with_image, **attributes] }
  let(:model) { Factory[:model] }

  let :attributes do
    {
      id: 1,
      model_id: model.id,
      label: "Test",
      name: "test",
      created_at: Time.new(2025, 1, 1, 0, 0, 0),
      updated_at: Time.new(2025, 1, 1, 0, 0, 0)
    }
  end

  describe "#to_h" do
    it "answers hash with image attributes" do
      expect(serializer.to_h).to match(
        id: 1,
        model_id: model.id,
        label: "Test",
        name: "test",
        uri: "memory://abc123.png",
        filename: "test.png",
        bit_depth: 1,
        mime_type: "image/png",
        width: 1,
        height: 1,
        size: 1,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      )
    end

    it "answers hash without image attributes" do
      serializer = described_class.new Factory[:screen, **attributes]

      expect(serializer.to_h).to match(
        id: 1,
        model_id: model.id,
        label: "Test",
        name: "test",
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      )
    end
  end
end
