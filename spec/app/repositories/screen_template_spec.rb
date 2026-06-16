# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::ScreenTemplate, :db do
  subject(:repository) { described_class.new }

  let(:template) { Factory[:screen_template] }

  describe "#all" do
    it "answers records" do
      template
      expect(repository.all).to contain_exactly(template)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(template.id).id).to eq(template.id)
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
      expect(repository.find_by(name: template.name).id).to eq(template.id)
    end

    it "answers record when found by multiple attributes" do
      expect(repository.find_by(name: template.name, label: template.label).id).to eq(template.id)
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#search" do
    before { template }

    it "answers records for case insensitive value" do
      name = template.name
      expect(repository.search(:name, name.upcase)).to contain_exactly(have_attributes(name:))
    end

    it "answers records for partial value" do
      name = template.name
      expect(repository.search(:name, name[..1])).to contain_exactly(have_attributes(name:))
    end

    it "answers empty array for invalid value" do
      expect(repository.search(:name, "bogus")).to eq([])
    end
  end

  describe "#where" do
    before { template }

    it "answers record for single attribute" do
      ids = repository.where(name: template.name).map(&:id)
      expect(ids).to contain_exactly(template.id)
    end

    it "answers record for multiple attributes" do
      ids = repository.where(name: template.name, label: template.label).map(&:id)
      expect(ids).to contain_exactly(template.id)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(name: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(name: nil)).to eq([])
    end
  end
end
