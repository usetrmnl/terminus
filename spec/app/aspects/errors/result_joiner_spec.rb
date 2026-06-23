# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Errors::ResultJoiner do
  subject(:joiner) { described_class }

  describe "#call" do
    let(:result) { instance_double Dry::Schema::Result, errors: }
    let(:errors) { {one: ["is missing"]} }

    it "answers string if a string" do
      expect(joiner.call("Test", "Danger!")).to eq("Danger!")
    end

    it "answers single error" do
      expect(joiner.call("Test", result)).to eq("Test one is missing.")
    end

    it "answers multiple errors with single issues" do
      errors[:two] = ["is missing"]
      expect(joiner.call("Test", result)).to eq("Test one is missing and two is missing.")
    end

    it "answers multiple errors with mixed issues" do
      errors[:two] = ["is missing", "must be a symbol"]

      expect(joiner.call("Test", result)).to eq(
        "Test one is missing and two is missing and must be a symbol."
      )
    end

    it "answers nested errors" do
      errors.replace({exchanges: {0 => {verb: ["is missing"]}}})
      expect(joiner.call("Test", result)).to eq("Test exchanges.0.verb is missing.")
    end
  end
end
