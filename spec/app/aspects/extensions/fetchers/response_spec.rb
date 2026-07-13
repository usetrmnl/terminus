# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Fetchers::Response do
  subject(:response) { described_class.new }

  describe "#initialize" do
    it "answers default attributes" do
      expect(response).to eq(described_class[data: {}, errors: {}])
    end
  end

  describe "#merge_data" do
    let(:response) { described_class[data: :test] }

    it "answers data merged with empty hash" do
      mutation = response.merge_data :source_1
      expect(mutation).to eq(source_1: :test)
    end

    it "answers data merged with existing hash" do
      mutation = response.merge_data :source_2, source_1: :one
      expect(mutation).to eq(source_1: :one, source_2: :test)
    end
  end

  describe "#merge_errors" do
    let(:response) { described_class[errors: :danger] }

    it "answers errors merged with empty hash" do
      mutation = response.merge_errors :source_1
      expect(mutation).to eq(source_1: :danger)
    end

    it "answers errors merged with existing hash" do
      mutation = response.merge_errors :source_2, source_1: :danger
      expect(mutation).to eq(source_1: :danger, source_2: :danger)
    end
  end
end
