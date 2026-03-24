# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Model, :db do
  subject(:repository) { described_class.new }

  let(:model) { Factory[:model] }

  describe "#all" do
    it "answers all records by published date/time" do
      model
      expect(repository.all.map(&:id)).to contain_exactly(model.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#delete_all" do
    it "answers all records for given attributes" do
      model
      Factory[:model, kind: "core"]
      repository.delete_all kind: ["core"]

      expect(repository.all.map(&:id)).to contain_exactly(model.id)
    end

    it "answers number of records deleted" do
      model
      Factory[:model, kind: "core"]

      expect(repository.delete_all).to eq(2)
    end

    it "answers zero when there is nothing to delete" do
      expect(repository.delete_all).to eq(0)
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(model.id)).to eq(model)
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
      expect(repository.find_by(name: model.name)).to eq(model)
    end

    it "answers record when found by multiple attributes" do
      model
      expect(repository.find_by(width: 800, height: 480)).to eq(model)
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#find_or_create" do
    it "answers existing record" do
      model
      record = repository.find_or_create :name, model.name, label: "Upsert"

      expect(record).to eq(model)
    end

    it "creates new record when record doesn't exist" do
      creation = repository.find_or_create :name, "test", label: "Upsert", width: 1, height: 1
      expect(creation).to have_attributes(name: "test", label: "Upsert", width: 1, height: 1)
    end
  end

  describe "#search" do
    let(:model) { Factory[:model, label: "Test"] }

    before { model }

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

  describe "#where" do
    it "answers record for single attribute" do
      expect(repository.where(label: model.label)).to contain_exactly(model)
    end

    it "answers record for multiple attributes" do
      expect(repository.where(label: model.label, name: model.name)).to contain_exactly(model)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(label: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(label: nil)).to eq([])
    end
  end
end
