# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Uploaders::Binary do
  subject(:uploader) { described_class }

  describe "#call" do
    let(:attacher) { uploader::Attacher.new }

    it "answers zero errors when valid" do
      attacher.assign StringIO.new([123].pack("N")), metadata: {"filename" => "test.bin"}
      expect(attacher.errors).to eq([])
    end

    it "answers errors when invalid" do
      SPEC_ROOT.join("support/fixtures/test.png")
               .read
               .then { attacher.assign StringIO.new(it) }

      expect(attacher.errors).to eq(
        [
          "type must be one of: application/octet-stream",
          "extension must be one of: bin"
        ]
      )
    end
  end
end
