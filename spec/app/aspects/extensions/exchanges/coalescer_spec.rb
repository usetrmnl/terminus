# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exchanges::Coalescer do
  subject(:coalescer) { described_class }

  describe "#call" do
    let :exchange do
      Factory.structs[:extension_exchange, data: {"source_1" => "a", "source_2" => "b"}]
    end

    it "answers data for single extension" do
      expect(coalescer.call([exchange])).to eq("source_1" => "a", "source_2" => "b")
    end

    it "answers data for multiple extensions" do
      expect(coalescer.call([exchange, exchange])).to eq(
        "source_1" => "a",
        "source_2" => "b",
        "source_3" => "a",
        "source_4" => "b"
      )
    end
  end
end
