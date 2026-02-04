# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Default do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        label: "Test",
        interval: 120
      }
    end

    it "answers default values" do
      expect(transformer.call(attributes)).to be_success(
        label: "Test",
        name: "test",
        description: "Imported from TRMNL.",
        interval: 2,
        unit: "minute"
      )
    end
  end
end
