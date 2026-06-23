# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Zipper do
  subject(:zipper) { described_class.new }

  describe "#call" do
    let(:manifest) { {"one.txt" => "One", "two.txt" => "Two"} }

    it "create zip file in memory" do
      io = zipper.call(manifest).value!

      content = Zip::File.open_buffer(io).each.with_object({}) do |entry, attributes|
        attributes[entry.name] = entry.get_input_stream.read
      end

      expect(content).to eq(manifest)
    end

    it "answers StringIO instance" do
      expect(zipper.call(manifest)).to match(Success(kind_of(StringIO)))
    end

    it "answers failure with invalid type" do
      expect(zipper.call({bogus: Object.new})).to be_failure(
        "No implicit conversion of Object into String"
      )
    end

    it "answers failure with zip error" do
      stream = class_double Zip::OutputStream
      zipper = described_class.new output_stream: stream

      allow(stream).to receive(:write_buffer).and_raise(Zip::Error, "Danger!")

      expect(zipper.call({test: "test"})).to be_failure("Danger!")
    end
  end
end
