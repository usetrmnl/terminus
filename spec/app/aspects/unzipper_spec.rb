# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Unzipper do
  subject(:unzipper) { described_class.new }

  before { Hanami.app.start :zip }

  describe "#call" do
    let :io do
      stream = Zip::OutputStream.write_buffer do |buffer|
        buffer.put_next_entry "test.txt"
        buffer.write "Test"
      end

      stream.tap(&:rewind)
    end

    it "answers extracted attributes" do
      expect(unzipper.call(io)).to be_success("test.txt" => "Test")
    end

    it "answers failure when type error" do
      expect(unzipper.call(StringIO.new)).to be_failure(
        "No implicit conversion of StringIO into String"
      )
    end

    it "answers failure when zip can't be decompressed" do
      file = class_double Zip::File
      unzipper = described_class.new(file:)

      allow(file).to receive(:open_buffer).and_raise Zip::Error, "Danger!"

      expect(unzipper.call(666)).to be_failure("Danger!")
    end
  end
end
