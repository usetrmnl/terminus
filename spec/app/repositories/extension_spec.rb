# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Extension, :db do
  subject(:repository) { described_class.new }

  let(:extension) { Factory[:extension] }

  describe "#all" do
    it "answers all records by published date/time" do
      extension
      expect(repository.all.map(&:id)).to contain_exactly(extension.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#create_with_devices" do
    let(:device) { Factory[:device] }
    let(:union_repository) { Terminus::Repositories::ExtensionDevice.new }

    it "answers record" do
      record = repository.create_with_devices({name: "test", label: "Test"}, [device.id])
      expect(record).to have_attributes(name: "test", label: "Test")
    end

    it "creates associations" do
      extension = repository.create_with_devices({name: "test", label: "Test"}, [device.id])

      expect(union_repository.all).to include(
        having_attributes(extension_id: extension.id, device_id: device.id)
      )
    end

    it "doesn't create record when IDs are invalid" do
      repository.create_with_devices({name: "test", label: "Test"}, [13])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(repository.all).to eq([])
    end

    it "doesn't associations when IDs are invalid" do
      repository.create_with_devices({name: "test", label: "Test"}, [13])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(union_repository.all).to eq([])
    end
  end

  describe "#create_with_models" do
    let(:model) { Factory[:model] }
    let(:union_repository) { Terminus::Repositories::ExtensionModel.new }

    it "answers record" do
      record = repository.create_with_models({name: "test", label: "Test"}, [model.id])
      expect(record).to have_attributes(name: "test", label: "Test")
    end

    it "creates associations" do
      extension = repository.create_with_models({name: "test", label: "Test"}, [model.id])

      expect(union_repository.all).to include(
        having_attributes(extension_id: extension.id, model_id: model.id)
      )
    end

    it "doesn't create record when IDs are invalid" do
      repository.create_with_models({name: "test", label: "Test"}, [13])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(repository.all).to eq([])
    end

    it "doesn't associations when IDs are invalid" do
      repository.create_with_models({name: "test", label: "Test"}, [13])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(union_repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(extension.id).id).to eq(extension.id)
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
      expect(repository.find_by(name: extension.name).id).to eq(extension.id)
    end

    it "answers record when found by multiple attributes" do
      extension

      expect(repository.find_by(name: extension.name, label: extension.label).id).to eq(
        extension.id
      )
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#search" do
    let(:extension) { Factory[:extension, label: "Test"] }

    before { extension }

    it "answers records for case insensitive value" do
      expect(repository.search(:label, "test")).to contain_exactly(have_attributes(label: "Test"))
    end

    it "answers records for partial value" do
      expect(repository.search(:label, "te")).to contain_exactly(have_attributes(label: "Test"))
    end

    it "answers empty array for invalid value" do
      expect(repository.search(:label, "bogus")).to eq([])
    end
  end

  describe "#update_with_devices" do
    let(:device) { Factory[:device] }
    let(:union_repository) { Terminus::Repositories::ExtensionDevice.new }

    it "answers record" do
      record = repository.update_with_devices extension.id,
                                              {name: "test", label: "Test"},
                                              [device.id]
      expect(record).to have_attributes(name: "test", label: "Test")
    end

    it "creates missing associations" do
      repository.update_with_devices extension.id, {name: "test", label: "Test"}, [device.id]

      expect(union_repository.all).to include(
        having_attributes(extension_id: extension.id, device_id: device.id)
      )
    end

    it "adds and subtracts associations" do
      repository.update_with_devices extension.id, {name: "test", label: "Test"}, [device.id]
      repository.update_with_devices extension.id, {name: "test", label: "Test"}, []

      expect(union_repository.all).to eq([])
    end
  end

  describe "#update_with_models" do
    let(:model) { Factory[:model] }
    let(:union_repository) { Terminus::Repositories::ExtensionModel.new }

    it "answers record" do
      record = repository.update_with_models extension.id, {name: "test", label: "Test"}, [model.id]
      expect(record).to have_attributes(name: "test", label: "Test")
    end

    it "creates missing associations" do
      repository.update_with_models extension.id, {name: "test", label: "Test"}, [model.id]

      expect(union_repository.all).to include(
        having_attributes(extension_id: extension.id, model_id: model.id)
      )
    end

    it "adds and subtracts associations" do
      repository.update_with_models extension.id, {name: "test", label: "Test"}, [model.id]
      repository.update_with_models extension.id, {name: "test", label: "Test"}, []

      expect(union_repository.all).to eq([])
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      expect(repository.where(label: extension.label)).to contain_exactly(extension)
    end

    it "answers record for multiple attributes" do
      records = repository.where label: extension.label, name: extension.name
      expect(records).to contain_exactly(extension)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(label: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(label: nil)).to eq([])
    end
  end
end
