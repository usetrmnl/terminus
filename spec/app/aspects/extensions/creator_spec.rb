# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Creator, :db do
  subject(:creator) { described_class.new }

  describe "#call" do
    let(:attributes) { {extension: {label: "Test", name: "test"}, model_ids: [], device_ids: []} }

    let :validator do
      Dry::Schema.Params do
        required(:extension).filled :hash do
          required(:label).filled :string
          required(:name).filled :string
        end

        required(:model_ids).array :integer
        required(:device_ids).array :integer
      end
    end

    it "creates extension" do
      expect(creator.call(attributes, validator:).value!).to have_attributes(
        label: "Test",
        name: "test"
      )
    end

    it "creates extension with associated model" do
      model = Factory[:model]
      attributes[:model_ids] = [model.id]
      repository = Terminus::Repositories::ExtensionModel.new
      extension = creator.call(attributes, validator:).value!

      expect(repository.find_by(model_id: model.id)).to have_attributes(
        extension_id: extension.id,
        model_id: model.id
      )
    end

    it "creates extension with associated device" do
      device = Factory[:device]
      attributes[:device_ids] = [device.id]
      repository = Terminus::Repositories::ExtensionDevice.new
      extension = creator.call(attributes, validator:).value!

      expect(repository.find_by(device_id: device.id)).to have_attributes(
        extension_id: extension.id,
        device_id: device.id
      )
    end

    it "upserts job schedule" do
      schedule = instance_spy Terminus::Aspects::Jobs::Schedule
      creator = described_class.new(schedule:)

      creator.call(attributes, validator:)

      expect(schedule).to have_received(:upsert).with("extension-test", {})
    end

    it "answers extension" do
      expect(creator.call(attributes, validator:)).to match(Success(Terminus::Structs::Extension))
    end

    it "answers failure with invalid attributes" do
      attributes[:extension].delete :label

      expect(creator.call(attributes, validator:).failure.errors.to_h).to eq(
        extension: {label: ["is missing"]}
      )
    end
  end
end
