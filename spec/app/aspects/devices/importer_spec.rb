# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::Importer, :db do
  subject(:importer) { described_class.new }

  describe "#call" do
    let(:repository) { Terminus::Repositories::Device.new }
    let(:model) { Factory[:model, name: "og_plus"] }
    let(:playlist) { Factory[:playlist, name: "test"] }
    let(:content) { SPEC_ROOT.join("support/fixtures/devices.csv").read }

    it "answers success with devices" do
      model
      playlist
      mac_addresses = importer.call(content).value![:devices].map(&:mac_address)

      expect(mac_addresses).to eq(%w[1E:B2:16:6D:7B:AB DA:D5:B9:A0:D1:5F])
    end

    it "answers failures when model can't be found" do
      expect(importer.call(content)).to be_failure(
        errors: [
          %(Unable to find model by name: "og_plus".),
          %(Unable to find model by name: "og_plus".)
        ]
      )
    end

    it "answers failures when playlist can't be found" do
      model

      expect(importer.call(content).failure).to match(
        devices: array_including(having_attributes(mac_address: "DA:D5:B9:A0:D1:5F")),
        errors: [%(Unable to find playlist by name: "test".)]
      )
    end
  end
end
