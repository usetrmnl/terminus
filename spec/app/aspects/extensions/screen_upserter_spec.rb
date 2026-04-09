# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::ScreenUpserter, :db do
  using Refinements::Struct

  subject(:upserter) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension, label: "Test", name: "test"] }
    let(:model) { Factory[:model] }
    let(:device) { Factory[:device, model_id: model.id] }

    let :proof do
      {
        model_id: model.id,
        name: "extension-test",
        label: "Extension Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 800,
            height: 480,
            filename: "extension-test.png",
            mime_type: "image/png"
          )
        )
      }
    end

    it "creates screen for model" do
      result = upserter.call extension, model_id: model.id
      expect(result.success).to have_attributes(proof)
    end

    it "creates screen for device" do
      result = upserter.call extension, device_id: device.id
      expect(result.success).to have_attributes(proof)
    end

    it "updates screen for model" do
      Factory[:screen, model_id: model.id, label: "Extension Test", name: "extension-test"]
      result = upserter.call extension, model_id: model.id

      expect(result.success).to have_attributes(proof)
    end

    it "updates screen for device" do
      Factory[:screen, model_id: model.id, label: "Extension Test", name: "extension-test"]
      result = upserter.call extension, device_id: device.id

      expect(result.success).to have_attributes(proof)
    end
  end
end
