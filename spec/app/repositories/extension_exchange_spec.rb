# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::ExtensionExchange, :db do
  subject(:repository) { described_class.new }

  let(:record) { Factory[:extension_exchange] }

  describe "#all" do
    it "answers all records" do
      record
      expect(repository.all.map(&:id)).to contain_exactly(record.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(record.id).id).to eq(record.id)
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
      expect(repository.find_by(extension_id: record.extension_id).id).to eq(record.id)
    end

    it "answers record when found by multiple attributes" do
      attributes = record.to_h.slice :extension_id, :model_id
      expect(repository.find_by(**attributes).id).to eq(record.id)
    end

    it "answers nil when not found" do
      expect(repository.find_by(extension_id: 13)).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(extension_id: nil)).to be(nil)
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      ids = repository.where(extension_id: record.extension_id).map(&:id)
      expect(ids).to contain_exactly(record.id)
    end

    it "answers record for multiple attributes" do
      ids = repository.where(**record.to_h.slice(:extension_id, :uri)).map(&:id)
      expect(ids).to contain_exactly(record.id)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(extension_id: 13)).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(extension_id: nil)).to eq([])
    end
  end
end
