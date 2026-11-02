# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Uploaders::Image do
  subject(:uploader) { described_class }

  describe "#call" do
    let(:attacher) { uploader::Attacher.new }

    it "answers bit depth when found" do
      path = SPEC_ROOT.join "support/fixtures/test.bmp"
      path.open { attacher.assign it }
      attributes = JSON attacher.column_values[nil], symbolize_names: true

      expect(attributes[:metadata]).to include(bit_depth: 1)
    end

    it "answers nil for bit depth when unknown" do
      attacher.assign StringIO.new
      attributes = JSON attacher.column_values[nil], symbolize_names: true

      expect(attributes[:metadata]).to include(bit_depth: nil)
    end

    it "answers checksum when found" do
      path = SPEC_ROOT.join "support/fixtures/test.png"
      path.open { attacher.assign it }
      attributes = JSON attacher.column_values[nil], symbolize_names: true

      expect(attributes[:metadata]).to include(checksum: match_md5_checksum)
    end

    it "answers checksum when unknown" do
      attacher.assign StringIO.new
      attributes = JSON attacher.column_values[nil], symbolize_names: true

      expect(attributes[:metadata]).to include(checksum: match_md5_checksum)
    end

    it "answers zero errors when valid BMP" do
      path = SPEC_ROOT.join "support/fixtures/test.bmp"
      path.open { attacher.assign it }

      expect(attacher.errors).to eq([])
    end

    it "answers zero errors when valid PNG" do
      path = SPEC_ROOT.join "support/fixtures/test.png"
      path.open { attacher.assign it }

      expect(attacher.errors).to eq([])
    end

    it "answers errors when invalid" do
      attacher.assign StringIO.new([123].pack("N"))

      expect(attacher.errors).to eq(
        [
          "type must be one of: image/bmp, image/png",
          "extension must be one of: bmp, png"
        ]
      )
    end
  end
end
