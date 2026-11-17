# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Designs::Cloner, :db do
  subject(:cloner) { described_class.new }

  describe "#call" do
    let(:repository) { Terminus::Repositories::ScreenTemplate.new }
    let(:original) { Factory[:screen_template, label: "Test", name: "test"] }
    let(:model) { Factory[:model] }

    it "clones without overrides" do
      clone = cloner.call(original.id, model_id: model.id).value!
      expect(clone).to have_attributes(label: "Test Clone", name: "test_clone")
    end

    it "clones with overrides" do
      overrides = {label: "Clone", name: "clone", content: "Test", mode: "dither"}
      clone = cloner.call(original.id, model_id: model.id, **overrides).value!

      expect(clone).to have_attributes(
        label: "Clone",
        name: "clone",
        content: "Test",
        mode: "dither"
      )
    end

    it "creates associated screen" do
      cloner.call original.id, model_id: model.id
      screen = Terminus::Repositories::Screen.new.find_by model_id: model.id

      expect(screen).to have_attributes(label: "Test Clone", name: "test_clone")
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
