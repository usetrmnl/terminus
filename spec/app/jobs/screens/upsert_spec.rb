# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Screens::Upsert, :db do
  subject(:job) { described_class.new }

  describe "#perform" do
    let(:model) { Factory[:model] }

    it "creates screen" do
      result = job.perform model.id, name: "test", label: "Test", content: "<h1>Test</h1>"

      expect(result.success).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          id: kind_of(String),
          metadata: kind_of(Hash),
          storage: "store"
        )
      )
    end

    it "updates screen" do
      Factory[:screen, model_id: model.id, label: "First", name: "test"]
      result = job.perform model.id, name: "test", label: "Update", content: "<h1>Test</h1>"

      expect(result.success).to have_attributes(model_id: model.id, name: "test", label: "Update")
    end
  end
end
