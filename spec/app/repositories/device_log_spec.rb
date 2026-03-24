# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::DeviceLog, :db do
  subject(:repository) { described_class.new }

  let(:log) { Factory[:device_log] }

  describe "#all" do
    it "answers records" do
      log
      expect(repository.all.map(&:id)).to contain_exactly(log.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(log.id)).to eq(log)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(13)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#delete_by_device" do
    it "deletes record when given device and record IDs" do
      repository.delete_by_device log.device_id, log.id
      expect(repository.find(log.id)).to be(nil)
    end

    it "doesn't delete record for invalid device ID and valid log ID" do
      repository.delete_by_device nil, log.id
      expect(repository.find(log.id)).to eq(log)
    end

    it "doesn't delete record for valid device ID and invalid log ID" do
      repository.delete_by_device log.device_id, 13_000_000
      expect(repository.find(log.id)).to eq(log)
    end
  end

  describe "#delete_all_by_device" do
    it "deletes associated logs" do
      id = log.device_id
      repository.delete_all_by_device id

      expect(repository.all).to eq([])
    end
  end

  describe "#search" do
    it "answers records for case insensitive value and device ID" do
      expect(repository.search(:message, "danger", device_id: log.device_id)).to contain_exactly(
        have_attributes(id: log.id, device_id: log.device_id, message: "Danger!")
      )
    end

    it "answers records for partial value and device ID" do
      expect(repository.search(:message, "dang", device_id: log.device_id)).to contain_exactly(
        have_attributes(id: log.id, device_id: log.device_id, message: "Danger!")
      )
    end

    it "answers empty array for valid value and invalid device ID" do
      expect(repository.search(:message, "Danger!", device_id: 13)).to eq([])
    end

    it "answers empty array for invalid value and valid device ID" do
      expect(repository.search(:message, "bogus", device_id: log.device_id)).to eq([])
    end
  end

  describe "#where" do
    it "answers records" do
      expect(repository.where(device_id: log.device_id)).to contain_exactly(
        have_attributes(id: log.id, device_id: log.device_id)
      )
    end

    it "answers empty array when records don't exist" do
      expect(repository.where(device_id: 13)).to eq([])
    end

    it "answers empty array when not found" do
      expect(repository.where(device_id: 13, refresh_rate: 1)).to eq([])
    end

    it "answers empty array when nil" do
      expect(repository.where(refresh_rate: nil)).to eq([])
    end
  end
end
