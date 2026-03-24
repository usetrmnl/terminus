# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Device, :db do
  subject(:repository) { described_class.new }

  let(:device) { Factory[:device] }

  describe "#all" do
    it "answers all records" do
      device
      expect(repository.all.map(&:id)).to contain_exactly(device.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      record = repository.find(device.id).to_h.tap { it.delete :playlist }
      expect(record).to eq(device.to_h)
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
      record = repository.find_by(label: device.label).to_h.tap { it.delete :playlist }
      expect(record).to eq(device.to_h)
    end

    it "answers record when found by multiple attributes" do
      record = repository.find_by(label: device.label, friendly_id: device.friendly_id)
                         .to_h
                         .tap { it.delete :playlist }

      expect(record).to eq(device.to_h)
    end

    it "answers nil when not found" do
      expect(repository.find_by(label: "Bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(label: nil)).to be(nil)
    end
  end

  describe "#mirror_playlist" do
    let(:playlist) { Factory[:playlist] }

    it "updates records with new playlist ID" do
      repository.mirror_playlist [device.id], playlist.id
      record = repository.find device.id

      expect(record.playlist_id).to eq(playlist.id)
    end

    it "answers one when success" do
      result = repository.mirror_playlist [device.id], playlist.id
      expect(result).to eq(1)
    end

    it "answers zero when there is nothing to update" do
      result = repository.mirror_playlist [], playlist.id
      expect(result).to eq(0)
    end
  end

  describe "#search" do
    before { device }

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

  describe "#update_by_mac_address" do
    it "updates record with attributes" do
      device
      update = repository.update_by_mac_address device.mac_address,
                                                label: "Update",
                                                friendly_id: "ABCDEF"

      expect(update).to have_attributes(label: "Update", friendly_id: "ABCDEF")
    end

    it "answers record without updates for no attributes" do
      update = repository.update_by_mac_address(device.mac_address).to_h.tap { it.delete :playlist }
      expect(update).to eq(device.to_h)
    end

    it "answers nil when device can't be found" do
      update = repository.update_by_mac_address "bogus"
      expect(update).to be(nil)
    end
  end

  describe "#where" do
    it "answers record for label" do
      records = repository.where(label: device.label).map { it.to_h.tap { it.delete :playlist } }
      expect(records).to contain_exactly(device.to_h)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(label: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(label: nil)).to eq([])
    end
  end
end
