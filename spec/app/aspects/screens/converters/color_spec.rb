# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Converters::Color do
  using Refinements::Struct

  subject(:converter) { described_class.new }

  include_context "with temporary directory"
  include_context "with screen mold"

  before { Hanami.app.start :mini_magick }

  describe "#call" do
    before do
      mold.with! color_codes: %w[#000000 #FF0000 #FFFFFF],
                 input_path: SPEC_ROOT.join("support/fixtures/test.png"),
                 output_path: temp_dir.join("test.png")
    end

    it "converts to color image" do
      converter.call mold
      image = MiniMagick::Image.new mold.output_path

      expect(image).to have_attributes(
        dimensions: [800, 480],
        exif: {},
        type: "PNG",
        data: hash_including(
          "colormap" => %w[#000000FF #FFFFFFFF],
          "colorspace" => "Gray",
          "depth" => 1,
          "mimeType" => "image/png"
        )
      )
    end

    it "rotates image" do
      converter.call mold.with(rotation: 90)
      image = MiniMagick::Image.new mold.output_path

      expect(image).to have_attributes(
        dimensions: [800, 480],
        exif: {},
        type: "PNG",
        data: hash_including(
          "colormap" => %w[#000000FF #FFFFFFFF],
          "colorspace" => "Gray",
          "depth" => 1,
          "mimeType" => "image/png"
        )
      )
    end

    it "crops image" do
      converter.call mold.with(offset_x: 10, offset_y: 10)
      image = MiniMagick::Image.new mold.output_path

      expect(image).to have_attributes(
        dimensions: [790, 470],
        exif: {},
        type: "PNG",
        data: hash_including(
          "colormap" => %w[#000000FF #FFFFFFFF],
          "colorspace" => "Gray",
          "depth" => 1,
          "mimeType" => "image/png"
        )
      )
    end

    it "converts WEBP image" do
      converter.call mold.with(palette_name: "24bit", mime_type: "image/webp")
      image = MiniMagick::Image.new mold.output_path

      expect(image).to have_attributes(
        dimensions: [800, 480],
        exif: {},
        type: "WEBP",
        data: hash_including("colorspace" => "sRGB", "mimeType" => "image/webp")
      )
    end

    it "answers path" do
      expect(converter.call(mold)).to be_success(mold.output_path)
    end

    it "answers failure when MiniMagick can't convert" do
      mini_magick = class_double MiniMagick
      allow(mini_magick).to receive(:convert).and_raise(MiniMagick::Error, "Danger!")
      converter = described_class.new(mini_magick:)

      expect(converter.call(mold)).to be_failure("Danger!")
    end
  end
end
