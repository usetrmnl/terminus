# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Relations::Firmware, :db do
  subject(:relation) { Hanami.app["relations.firmware"] }

  describe "#with_model_join" do
    let(:firmware) { Factory[:firmware, version: "1.2.3"] }
    let(:join) { Factory[:firmware_model, firmware_id: firmware.id] }

    before { join }

    it "answers firmware for version and model ID" do
      query = relation.with_model_join model_id: join.model_id, version: firmware.version
      expect(query).to include(hash_including(id: firmware.id, version: "1.2.3"))
    end

    it "answers firmware for version and model name" do
      query = relation.with_model_join name: join.model.name, version: firmware.version
      expect(query).to include(hash_including(id: firmware.id, version: "1.2.3"))
    end

    it "answers nil with invalid model ID" do
      expect(relation.with_model_join(model_id: 666, version: firmware.version)).to eq([])
    end

    it "answers nil with invalid version" do
      expect(relation.with_model_join(model_id: join.model_id, version: "0.0.0")).to eq([])
    end
  end

  describe "#by_version_desc" do
    it "orders by descending version" do
      one = Factory[:firmware, version: "0.0.1"]
      ten = Factory[:firmware, version: "0.0.10"]
      five = Factory[:firmware, version: "0.0.5"]

      expect(relation.by_version_desc.to_a).to eq([ten, five, one].map(&:to_h))
    end
  end
end
