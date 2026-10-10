# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Firmware::Updater, :db do
  subject(:updater) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        id: firmware.id,
        firmware: {
          version: "1.2.3"
        },
        model_ids: [model.id]
      }
    end

    let(:model) { Factory[:model] }
    let(:firmware) { Factory[:firmware, :with_model, :with_attachment] }
    let(:io) { StringIO.new }

    let :validator do
      Dry::Schema.Params do
        required(:id).filled :integer

        required(:firmware).filled :hash do
          required(:version).filled Terminus::Types::Version
        end

        required(:model_ids).array :integer
      end
    end

    it "updates firmware" do
      expect(updater.call(attributes, io, validator:).value!).to have_attributes(
        version: "1.2.3",
        attachment_attributes: hash_including(
          metadata: hash_including(size: kind_of(Integer), filename: "1.2.3.bin")
        )
      )
    end

    it "updates firmware with different model" do
      model = Factory[:model]
      attributes[:model_ids] = [model.id]
      repository = Terminus::Repositories::FirmwareModel.new
      firmware = updater.call(attributes, io, validator:).value!

      expect(repository.find_by(model_id: model.id)).to have_attributes(
        firmware_id: firmware.id,
        model_id: model.id
      )
    end

    it "answers firmware" do
      expect(updater.call(attributes, io, validator:)).to match(Success(Terminus::Structs::Firmware))
    end

    it "answers failure with invalid attributes" do
      attributes[:firmware].delete :version

      expect(updater.call(attributes, io, validator:).failure.errors.to_h).to eq(
        firmware: ["must be filled"]
      )
    end
  end
end
