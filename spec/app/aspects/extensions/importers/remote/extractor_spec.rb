# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Extractor do
  subject(:extractor) { described_class.new }

  describe "#call" do
    it "successfully extracts content" do
      expect(extractor.call(150460)).to match(
        Success(
          hash_including(
            settings: kind_of(String),
            full: kind_of(String),
            half_horizontal: kind_of(String),
            half_vertical: kind_of(String),
            quadrant: kind_of(String),
            shared: kind_of(String)
          )
        )
      )
    end
  end
end
