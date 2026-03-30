# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Mold do
  using Refinements::Struct

  subject :mold do
    described_class[
      model_id: 1,
      name: "test",
      label: "Test",
      content: "test",
      mime_type: "image/png",
      bit_depth: 4,
      rotation: 0,
      offset_x: 0,
      offset_y: 0,
      width: 800,
      height: 480
    ]
  end

  let(:model) { Factory.structs[:model, bit_depth: 1, colors: 2] }

  describe "#color?" do
    it "answers true with dither mode, positive bit depth, and color codes" do
      expect(mold.with(mode: "dither", bit_depth: 1, color_codes: ["#000000"]).color?).to be(true)
    end

    it "answers false with color codes are missing" do
      expect(mold.with(mode: "dither", bit_depth: 1, color_codes: nil).color?).to be(false)
    end

    it "answers false when missing required attributes" do
      expect(mold.color?).to be(false)
    end
  end

  describe "#crop" do
    it "answers width, height, x offset, and y offset" do
      expect(mold.with(offset_x: 10, offset_y: 20).crop).to eq("800x480+10+20")
    end
  end

  describe "#cropable?" do
    it "answers true if x offset is positive" do
      expect(mold.with(offset_x: 1).cropable?).to be(true)
    end

    it "answers true if x offset is negative" do
      expect(mold.with(offset_x: -1).cropable?).to be(true)
    end

    it "answers true if y offset is positive" do
      expect(mold.with(offset_y: 1).cropable?).to be(true)
    end

    it "answers true if y offset is negative" do
      expect(mold.with(offset_y: -1).cropable?).to be(true)
    end

    it "answers false if x and y offsets are zero" do
      expect(mold.cropable?).to be(false)
    end
  end

  describe "#dither?" do
    it "answers true when mode is dither" do
      expect(mold.with(mode: "dither").dither?).to be(true)
    end

    it "answers false when mode isn't dither" do
      expect(mold.dither?).to be(false)
    end
  end

  describe "#dimensions" do
    it "answers dimensions" do
      expect(mold.dimensions).to eq("800x480")
    end
  end

  describe "#file_name" do
    it "answers file name" do
      expect(mold.file_name).to eq("test.png")
    end
  end

  describe "#file_type" do
    it "answers BMP3 when MIME Type is BMP" do
      expect(mold.with(mime_type: "bmp").file_type).to eq("bmp3")
    end

    it "answers PNG when MIME Type is PNG" do
      expect(mold.file_type).to eq("png")
    end
  end

  describe "#image?" do
    it "answers true with image MIME type" do
      expect(mold.image?).to be(true)
    end

    it "answers false without image MIME type" do
      expect(mold.with(mime_type: "text/html").image?).to be(false)
    end
  end

  describe "#image_attributes" do
    it "answers image attributes for screen attachments" do
      expect(mold.image_attributes).to eq(model_id: 1, label: "Test", name: "test")
    end
  end

  describe "#rotatable?" do
    it "answers true when rotation is positive" do
      expect(mold.with(rotation: 90).rotatable?).to be(true)
    end

    it "answers true when rotation is negative" do
      expect(mold.with(rotation: -90).rotatable?).to be(true)
    end

    it "answers false when rotation is zero" do
      expect(mold.rotatable?).to be(false)
    end
  end

  describe "#viewport" do
    it "answers viewport specific attributes" do
      viewport = {width: 800, height: 480}
      expect(mold.with(**viewport).viewport).to eq(viewport)
    end
  end
end
