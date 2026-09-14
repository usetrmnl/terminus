# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Updater, :db do
  subject(:updater) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension, label: "Initial", name: "initial"] }

    let :attributes do
      {
        id: extension.id,
        extension: {label: "Test", name: "test"},
        model_ids: [],
        device_ids: []
      }
    end

    let :validator do
      Dry::Schema.Params do
        required(:id).filled :integer

        required(:extension).filled :hash do
          required(:label).filled :string
          required(:name).filled :string
        end

        required(:model_ids).array :integer
        required(:device_ids).array :integer
      end
    end

    it "updates extension" do
      expect(updater.call(attributes, validator:).value!).to have_attributes(
        label: "Test",
        name: "test"
      )
    end

    it "updates extension with associated model" do
      model = Factory[:model]
      attributes[:model_ids] = [model.id]
      repository = Terminus::Repositories::ExtensionModel.new
      updater.call(attributes, validator:)

      expect(repository.find_by(model_id: model.id)).to have_attributes(
        extension_id: extension.id,
        model_id: model.id
      )
    end

    it "updates extension with associated device" do
      device = Factory[:device]
      attributes[:device_ids] = [device.id]
      repository = Terminus::Repositories::ExtensionDevice.new
      updater.call(attributes, validator:)

      expect(repository.find_by(device_id: device.id)).to have_attributes(
        extension_id: extension.id,
        device_id: device.id
      )
    end

    it "upserts job schedule" do
      schedule = instance_spy Terminus::Aspects::Jobs::Schedule
      updater = described_class.new(schedule:)

      updater.call(attributes, validator:)

      expect(schedule).to have_received(:upsert).with(
        "extension-test",
        {},
        old_name: "extension-test"
      )
    end

    it "answers extension" do
      expect(updater.call(attributes, validator:)).to match(Success(Terminus::Structs::Extension))
    end

    it "answers failure when extension can't be found" do
      attributes[:id] = 666

      expect(updater.call(attributes, validator:)).to be_failure(
        "Unable to find extension ID: 666."
      )
    end

    it "answers failure with invalid attributes" do
      attributes[:extension].delete :label
      extension, result = updater.call(attributes, validator:).failure

      expect([extension, result.errors.to_h]).to match(
        [
          kind_of(Terminus::Structs::Extension),
          {
            extension: {
              label: ["is missing"]
            }
          }
        ]
      )
    end
  end
end
