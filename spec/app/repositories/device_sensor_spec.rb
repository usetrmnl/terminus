# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::DeviceSensor, :db do
  subject(:repository) { described_class.new }

  let(:sensor) { Factory[:device_sensor] }

  describe "#all" do
    it "answers records" do
      sensor
      expect(repository.all.map(&:id)).to contain_exactly(sensor.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(sensor.id)).to eq(sensor)
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
      record = repository.find_by make: sensor.make
      expect(record).to eq(sensor)
    end

    it "answers record when found by multiple attributes" do
      record = repository.find_by make: sensor.make, model: sensor.model
      expect(record).to eq(sensor)
    end

    it "answers nil when not found" do
      expect(repository.find_by(make: "Bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(make: nil)).to be(nil)
    end
  end

  describe "#limited_where" do
    let(:other) { Factory[:device_sensor] }

    before do
      sensor
      other
    end

    it "answers records for default limit" do
      expect(repository.limited_where).to contain_exactly(
        have_attributes(id: sensor.id, device_id: sensor.device_id),
        have_attributes(id: other.id, device_id: other.device_id)
      )
    end

    it "answers records for specific attributes" do
      expect(repository.limited_where(id: sensor.id)).to contain_exactly(
        have_attributes(id: sensor.id, device_id: sensor.device_id)
      )
    end

    it "answers records for specific limit" do
      expect(repository.limited_where(1)).to contain_exactly(
        have_attributes(id: sensor.id, device_id: sensor.device_id)
      )
    end
  end

  describe "#search" do
    it "answers records for case insensitive value and device ID" do
      expect(repository.search(:make, "ACME", device_id: sensor.device_id)).to contain_exactly(
        have_attributes(id: sensor.id, device_id: sensor.device_id, make: "ACME")
      )
    end

    it "answers records for partial value and device ID" do
      expect(repository.search(:make, "AC", device_id: sensor.device_id)).to contain_exactly(
        have_attributes(id: sensor.id, device_id: sensor.device_id, make: "ACME")
      )
    end

    it "answers empty array for valid value and invalid device ID" do
      expect(repository.search(:make, "ACME", device_id: 13)).to eq([])
    end

    it "answers empty array for invalid value and valid device ID" do
      expect(repository.search(:make, "Bogus", device_id: sensor.device_id)).to eq([])
    end
  end

  describe "#where" do
    it "answers records" do
      expect(repository.where(device_id: sensor.device_id)).to contain_exactly(
        have_attributes(id: sensor.id, device_id: sensor.device_id)
      )
    end

    it "answers empty array when records don't exist" do
      expect(repository.where(device_id: 13)).to eq([])
    end

    it "answers empty array when not found" do
      expect(repository.where(device_id: 13, make: "ACME")).to eq([])
    end

    it "answers empty array when nil" do
      expect(repository.where(make: nil)).to eq([])
    end
  end
end
