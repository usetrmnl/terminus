# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Firmware, :db do
  subject(:repository) { described_class.new }

  let(:firmware) { Factory[:firmware] }

  describe "#add_attachment" do
    it "answers record with attachment" do
      attached = repository.add_attachment firmware, "0.0.0", StringIO.new("test")

      expect(attached).to have_attributes(
        version: "0.0.0",
        attachment_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: nil,
            height: nil,
            filename: "0.0.0.bin",
            mime_type: "application/octet-stream"
          )
        )
      )
    end
  end

  describe "#all" do
    it "answers all records" do
      firmware
      expect(repository.all.map(&:id)).to contain_exactly(firmware.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#create_with_models" do
    let(:model) { Factory[:model] }
    let(:union_repository) { Terminus::Repositories::FirmwareModel.new }

    it "answers record" do
      record = repository.create_with_models({version: "1.2.3"}, [model.id])
      expect(record).to have_attributes(version: "1.2.3")
    end

    it "creates associations" do
      firmware = repository.create_with_models({version: "1.2.3"}, [model.id])

      expect(union_repository.all).to include(
        having_attributes(firmware_id: firmware.id, model_id: model.id)
      )
    end

    it "doesn't create record when IDs are invalid" do
      repository.create_with_models({version: "1.2.3"}, [13])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(repository.all).to eq([])
    end

    it "doesn't associations when IDs are invalid" do
      repository.create_with_models({version: "1.2.3"}, [13])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(union_repository.all).to eq([])
    end
  end

  describe "#delete" do
    it "deletes existing record" do
      firmware
      repository.delete firmware.id

      expect(repository.all).to eq([])
    end

    it "deletes associated attachment" do
      upload = firmware.upload StringIO.new([123].pack("N"))
      repository.update firmware.id, attachment_data: upload.data
      repository.delete firmware.id

      expect(Hanami.app[:shrine].storages[:store].store).to eq({})
    end

    it "ignores unknown record" do
      repository.delete 13
      expect(repository.all).to eq([])
    end
  end

  describe "#delete_all" do
    before { firmware }

    it "deletes all records" do
      repository.delete_all
      expect(repository.all).to eq([])
    end

    it "deletes all attachments" do
      upload = firmware.upload StringIO.new([123].pack("N"))
      repository.update firmware.id, attachment_data: upload.data
      repository.delete_all

      expect(Hanami.app[:shrine].storages[:store].store).to eq({})
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(firmware.id).id).to eq(firmware.id)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(13)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#find_by" do
    it "answers record when found by single attribute" do
      expect(repository.find_by(version: firmware.version).id).to eq(firmware.id)
    end

    it "answers record when found by multiple attributes" do
      expect(repository.find_by(id: firmware.id, version: firmware.version).id).to eq(firmware.id)
    end

    it "answers nil when not found" do
      expect(repository.find_by(version: "6.6.6")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(version: nil)).to be(nil)
    end
  end

  describe "#latest" do
    it "answers latest record" do
      firmware
      two = Factory[:firmware, version: "0.1.0"]

      expect(repository.latest.id).to eq(two.id)
    end

    it "answers nil when records don't exist" do
      expect(repository.latest).to be(nil)
    end
  end

  describe "#search" do
    before { firmware }

    it "answers records for exact value" do
      expect(repository.search(:version, "0.0.0")).to contain_exactly(
        have_attributes(version: "0.0.0")
      )
    end

    it "answers records for partial value" do
      expect(repository.search(:version, "0.0")).to contain_exactly(
        have_attributes(version: "0.0.0")
      )
    end

    it "answers empty array for invalid value" do
      expect(repository.search(:version, "1.1.1")).to eq([])
    end
  end

  describe "#update_with_models" do
    let(:model) { Factory[:model] }
    let(:union_repository) { Terminus::Repositories::FirmwareModel.new }

    it "answers record" do
      record = repository.update_with_models firmware.id, {version: "1.2.3"}, [model.id]
      expect(record).to have_attributes(version: "1.2.3")
    end

    it "creates missing associations" do
      repository.update_with_models firmware.id, {version: "1.2.3"}, [model.id]

      expect(union_repository.all).to include(
        having_attributes(firmware_id: firmware.id, model_id: model.id)
      )
    end

    it "adds and subtracts associations" do
      repository.update_with_models firmware.id, {version: "1.2.3"}, [model.id]
      repository.update_with_models firmware.id, {version: "1.2.3"}, []

      expect(union_repository.all).to eq([])
    end
  end

  describe "#where_with_model" do
    before { Factory[:firmware_model, firmware_id: firmware.id] }

    it "answers record for single attribute" do
      expect(repository.where_with_model(version: firmware.version)).to contain_exactly(firmware)
    end

    it "answers record for multiple attributes" do
      records = repository.where_with_model firmware_id: firmware.id, version: firmware.version
      expect(records).to contain_exactly(firmware)
    end

    it "answers empty array for unknown value" do
      expect(repository.where_with_model(version: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where_with_model(version: nil)).to eq([])
    end
  end
end
