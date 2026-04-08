# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Cloner, :db do
  subject(:cloner) { described_class.new }

  describe "#call" do
    let(:repository) { Terminus::Repositories::Extension.new }
    let(:original) { Factory[:extension, label: "Test", name: "test"] }

    it "clones extension without overrides" do
      clone = cloner.call(original.id).value!
      expect(clone).to have_attributes(label: "Test Clone", name: "test_clone")
    end

    it "clones extension with overrides" do
      clone = cloner.call(original.id, kind: "static", template: "A test.").value!

      expect(clone).to have_attributes(
        label: "Test Clone",
        name: "test_clone",
        kind: "static",
        template: "A test."
      )
    end

    it "clones extension with models" do
      model = Factory[:model]
      original = repository.create_with_models({label: "Test", name: "test"}, [model.id])
      clone = cloner.call(original.id, model_ids: [model.id]).value!
      records = Terminus::Repositories::ExtensionModel.new.where extension_id: clone.id

      expect(records.map(&:model_id)).to contain_exactly(model.id)
    end

    it "clones extension with devices" do
      device = Factory[:device]
      repository.update_with_devices(original.id, {}, [device.id])
      clone = cloner.call(original.id, device_ids: [device.id]).value!
      records = Terminus::Repositories::ExtensionDevice.new.where extension_id: clone.id

      expect(records.map(&:device_id)).to contain_exactly(device.id)
    end

    it "clones extension with exchanges" do
      Factory[:extension_exchange, extension_id: original.id, template: "https://test.io"]
      clone = cloner.call(original.id).value!
      templates = Terminus::Repositories::ExtensionExchange.new
                                                           .where(extension_id: clone.id)
                                                           .map(&:template)

      expect(templates).to contain_exactly("https://test.io")
    end

    it "adds Sidekiq schedule" do
      schedule = instance_spy Terminus::Aspects::Jobs::Schedule
      cloner = described_class.new(schedule:)

      cloner.call original.id

      expect(schedule).to have_received(:upsert).with("extension-test_clone", kind_of(Hash))
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
