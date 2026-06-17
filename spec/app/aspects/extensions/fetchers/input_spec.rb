# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Fetchers::Input do
  subject(:input) { described_class.new uri: "https://test.io" }

  describe "#initialize" do
    it "answers default attributes" do
      expect(input).to eq(
        described_class[headers: {}, verb: "get", uri: "https://test.io", body: {}]
      )
    end
  end

  describe "#http_options" do
    it "answers empty hash for default body" do
      expect(input.http_options).to eq({})
    end

    it "answers empty hash when body is nil" do
      input = described_class.new uri: "https://test.io", body: nil
      expect(input.http_options).to eq({})
    end

    it "answers JSON when body is present" do
      input = described_class.new uri: "https://test.io", body: {name: :test}
      expect(input.http_options).to eq(json: {name: :test})
    end
  end
end
