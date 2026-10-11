# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Firmware do
  subject(:part) { described_class.new value: firmware, rendering: Terminus::View.new.rendering }

  let(:firmware) { Factory.structs[:firmware] }

  describe "#first_model_link" do
    it "answers link to model when models exist" do
      firmware.define_singleton_method(:models) { [Factory.structs[:model, id: 1, label: "Test"]] }
      expect(part.first_model_link).to eq(%(<a href="/models/1">Test</a>))
    end

    it "answers missing model when models are empty" do
      firmware.define_singleton_method(:models) { [] }
      expect(part.first_model_link).to eq("Missing Model")
    end
  end

  describe "#total_models" do
    it "answers total (one)" do
      firmware.define_singleton_method(:models) { [Factory.structs[:model]] }
      expect(part.total_models).to eq("1 model")
    end

    it "answers total (many)" do
      firmware.define_singleton_method :models do
        [
          Factory.structs[:model],
          Factory.structs[:model]
        ]
      end

      expect(part.total_models).to eq("2 models")
    end
  end
end
