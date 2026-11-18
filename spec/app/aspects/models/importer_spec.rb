# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Models::Importer, :db do
  subject(:importer) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:io) { Terminus::Aspects::Zipper.new.call({"configuration.yml" => configuration}).value! }
    let(:palette) { Factory[:palette] }

    let :configuration do
      <<~CONTENT
        version: 1.2.3
        label: Test
        name: test
        default_palette_name: #{palette.name}
      CONTENT
    end

    it "creates model" do
      relation = Hanami.app["relations.model"]
      expectation = proc { importer.call io }
      count = proc { relation.count }

      expect(&expectation).to change(&count).by(1)
    end

    it "associates default palette" do
      model = importer.call(io).value!
      expect(model.default_palette_id).to eq(palette.id)
    end

    it "answers success" do
      attributes = importer.call(io).success.to_h

      expect(attributes).to include(name: "test", label: "Test")
    end

    it "logs import details" do
      importer.call io
      expect(logger.reread).to match(/DEBUG.+Imported model.+model_id.+\d+/)
    end

    context "with invalid configuration" do
      let(:configuration) { "version: 1.2.3" }

      it "answers failure configuration is missing keys" do
        expect(importer.call(io)).to be_failure("Import label is missing and name is missing.")
      end
    end

    it "answers failure when model isn't unique" do
      Factory[:model, name: "test"]

      expect(importer.call(io)).to be_failure(
        %(Name must be unique. Please use a value other than "test".)
      )
    end
  end
end
