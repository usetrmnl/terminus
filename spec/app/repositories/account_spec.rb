# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Account, :db do
  subject(:repository) { described_class.new }

  let(:account) { Factory[:account] }

  describe "#all" do
    it "answers all records by created date/time" do
      account
      expect(repository.all.map(&:id)).to contain_exactly(account.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(account.id)).to have_attributes(account.to_h)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(666)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#find_by" do
    it "answers record when found by single attribute" do
      expect(repository.find_by(name: account.name)).to have_attributes(account.to_h)
    end

    it "answers record when found by multiple attributes" do
      expect(repository.find_by(name: account.name, label: account.label)).to have_attributes(
        account.to_h
      )
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#find_or_create" do
    it "finds existing record" do
      expect(repository.find_or_create(name: account.name)).to have_attributes(account.to_h)
    end

    it "creates record when not found" do
      expect(repository.find_or_create(name: "default", label: "Default")).to have_attributes(
        name: "default",
        label: "Default"
      )
    end
  end

  describe "#search" do
    let(:account) { Factory[:account, label: "Test"] }

    before { account }

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
      expect(repository.where(label: account.label)).to contain_exactly(account)
    end

    it "answers record for multiple attributes" do
      expect(repository.where(label: account.label, name: account.name)).to contain_exactly(account)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(label: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(label: nil)).to eq([])
    end
  end
end
