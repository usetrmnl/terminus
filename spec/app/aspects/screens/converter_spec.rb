# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Converter do
  using Refinements::Struct

  subject(:converter) { described_class.new }

  include_context "with temporary directory"
  include_context "with screen mold"

  before { Hanami.app.start :mini_magick }

  describe "#call" do
    before do
      mold.with! input_path: SPEC_ROOT.join("support/fixtures/test.png"),
                 output_path: temp_dir.join("test.png")
    end

    it "converts to color image" do
      converter.call mold.with(
        mode: "dither",
        grays: 2,
        bit_depth: 2,
        color_codes: %w[#000000 #FF0000 #FFFFFF]
      )

      image = MiniMagick::Image.open mold.output_path

      expect(image).to have_attributes(
        dimensions: [800, 480],
        exif: {},
        type: "PNG",
        data: hash_including(
          "colormap" => %w[#000000FF #FFFFFFFF],
          "colorspace" => "Gray",
          "depth" => 1,
          "mimeType" => "image/png",
          "type" => "Grayscale"
        )
      )
    end

    it "converts to monochrome image" do
      converter.call mold

      image = MiniMagick::Image.open mold.output_path

      expect(image).to have_attributes(
        dimensions: [800, 480],
        exif: {},
        type: "PNG",
        data: hash_including(
          "colormap" => %w[#000000FF #FFFFFFFF],
          "colorspace" => "Gray",
          "depth" => 1,
          "mimeType" => "image/png",
          "type" => "Grayscale"
        )
      )
    end

    it "answers image path" do
      expect(converter.call(mold)).to be_success(mold.output_path)
    end
  end
end
