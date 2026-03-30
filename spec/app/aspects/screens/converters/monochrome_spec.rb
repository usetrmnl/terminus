# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Converters::Monochrome do
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

    it "converts to one bit dither image" do
      converter.call mold.with(mode: "dither")
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

    it "converts to two bit dither image" do
      converter.call mold.with(mode: "dither", bit_depth: 2)
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

    it "converts to four bit dither image" do
      converter.call mold.with(mode: "dither", bit_depth: 4)
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

    it "converts to eight bit dither image" do
      converter.call mold.with(mode: "dither", bit_depth: 8)
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

    it "converts to one bit image" do
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

    it "converts to two bit image" do
      converter.call mold.with(bit_depth: 2)
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

    it "converts to eight bit image" do
      converter.call mold.with(bit_depth: 8)
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

    it "rotates image" do
      converter.call mold.with(rotation: 90)
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

    it "crops image" do
      converter.call mold.with(offset_x: 10, offset_y: 10)
      image = MiniMagick::Image.open mold.output_path

      expect(image).to have_attributes(
        dimensions: [790, 470],
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

    it "answers path" do
      expect(converter.call(mold)).to be_success(mold.output_path)
    end

    it "answers failure with unsupported bit depth" do
      mold.with! bit_depth: 13
      expect(converter.call(mold)).to be_failure("Unsupported monochrome bit depth: 13.")
    end

    it "answers failure when MiniMagick can't convert" do
      mini_magick = class_double MiniMagick
      allow(mini_magick).to receive(:convert).and_raise(MiniMagick::Error, "Danger!")
      converter = described_class.new(mini_magick:)

      expect(converter.call(mold)).to be_failure("Danger!")
    end
  end
end
