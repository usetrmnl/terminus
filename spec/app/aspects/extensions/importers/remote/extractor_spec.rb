# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Extractor do
  subject(:extractor) { described_class.new }

  describe "#call" do
    it "successfully imports plugin" do
      expect(extractor.call(150460)).to match(
        Success(
          hash_including(
            settings: start_with("---"),
            full: start_with("<div"),
            half_horizontal: start_with("<div"),
            half_vertical: start_with("<div"),
            quadrant: start_with("<div"),
            shared: start_with("<style>")
          )
        )
      )
    end

    it "answes failure when zip can't be decompressed" do
      client = class_double Zip::File
      extractor = described_class.new(client:)

      allow(client).to receive(:open_buffer).and_raise Zip::Error, "Danger!"

      expect(extractor.call(150460)).to be_failure("Danger!")
    end
  end
end
