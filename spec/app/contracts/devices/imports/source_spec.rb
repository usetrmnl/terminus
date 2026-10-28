# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Devices::Imports::Source do
  subject(:contract) { described_class.new }

  describe "#call" do
    let(:io) { StringIO.new }

    let :attributes do
      {
        devices: {
          attachment: {
            name: "test",
            type: "application/zip",
            head: "what",
            filename: "attachment.zip",
            tempfile: io
          }
        }
      }
    end

    it "answers success when attachment is valid" do
      expect(contract.call(attributes).success?).to be(true)
    end

    it "answers success when URI is valid" do
      attributes[:devices].delete :attachment
      attributes[:devices][:uri] = "https://test.io"

      expect(contract.call(attributes).success?).to be(true)
    end

    it "answers error when both attachment and URI are empty" do
      attributes[:devices][:uri] = nil
      attributes[:devices][:attachment] = nil

      expect(contract.call(attributes).errors.to_h).to eq(
        devices: ["attachment or uri must be filled"]
      )
    end

    it "answers error when both attachment and URI are present" do
      attributes[:devices][:uri] = "https://test.io"

      expect(contract.call(attributes).errors.to_h).to eq(
        devices: ["must provide either attachment or uri but not both"]
      )
    end

    it "answers errors when attachment size is too large" do
      io.write "x" * 512_001

      expect(contract.call(attributes).errors.to_h).to eq(
        devices: {attachment: ["must be less than 500.0 KB"]}
      )
    end
  end
end
