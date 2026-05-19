# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Serializers::Firmware do
  subject(:serializer) { described_class.new record }

  let(:record) { Factory.structs[:firmware, :with_attachment, **attributes] }

  let :attributes do
    {
      id: 1,
      version: "0.0.0",
      kind: "test",
      created_at: "2025-01-01T10:10:10+0000",
      updated_at: "2025-01-01T10:10:10+0000"
    }
  end

  describe "#to_h" do
    it "answers hash with attachment attributes" do
      expect(serializer.to_h).to eq(
        file_name: "0.0.0.bin",
        mime_type: "application/octet-stream",
        size: 4,
        uri: "memory://abc123.bin",
        **attributes
      )
    end

    it "answers hash without attachment" do
      serializer = described_class.new Factory.structs[:firmware, **attributes]
      expect(serializer.to_h).to eq(file_name: "0.0.0.bin", **attributes)
    end
  end
end
