# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Models::Cloner, :db do
  subject(:cloner) { described_class.new }

  describe "#call" do
    let(:repository) { Terminus::Repositories::Model.new }
    let(:original) { Factory[:model, label: "Test", name: "test"] }

    it "clones model without overrides" do
      clone = cloner.call(original.id).value!
      expect(clone).to have_attributes(label: "Test Clone", name: "test_clone", kind: "terminus")
    end

    it "clones model with overrides" do
      clone = cloner.call(original.id, colors: 256, scale_factor: 1.5).value!

      expect(clone).to have_attributes(
        label: "Test Clone",
        name: "test_clone",
        kind: "terminus",
        colors: 256,
        scale_factor: 1.5
      )
    end

    it "fails when label isn't unique" do
      clone = cloner.call original.id, label: original.label
      expect(clone).to be_failure(label: ["must be unique"])
    end

    it "fails when name isn't unique" do
      clone = cloner.call original.id, name: original.name
      expect(clone).to be_failure(name: ["must be unique"])
    end
  end
end
