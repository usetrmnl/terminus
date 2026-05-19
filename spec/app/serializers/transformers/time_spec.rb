# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Serializers::Transformers::Time do
  subject(:transformer) { described_class }

  describe "#call" do
    it "answers string when SQLTime" do
      expect(transformer.call(Sequel::SQLTime.new("2025-01-01T10:10:10+0000"))).to eq("10:10:10")
    end

    it "answers string when Time" do
      expect(transformer.call(Time.utc(2025, 1, 1, 10, 10, 10))).to eq("2025-01-01T10:10:10+00:00")
    end

    it "answers original value when not a SQLTime instance" do
      expect(transformer.call("test")).to eq("test")
    end

    it "answers nil when nil" do
      expect(transformer.call(nil)).to be(nil)
    end
  end
end
