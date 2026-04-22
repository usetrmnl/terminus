# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Models::PaletteOptioner, :db do
  subject(:optioner) { described_class.new }

  describe "#call" do
    let(:model) { Factory[:model] }
    let(:palette_a) { Factory[:palette] }
    let(:palette_b) { Factory[:palette] }

    before do
      palette_a
      palette_b
    end

    it "answers only palettes associated with model" do
      Factory[:model_palette, model_id: model.id, palette_id: palette_a.id]

      expect(optioner.call(model)).to eq([["Select...", ""], [palette_a.label, palette_a.id]])
    end

    it "answers all palettes when model isn't provided" do
      expect(optioner.call).to eq(
        [
          ["Select...", ""],
          [palette_a.label, palette_a.id],
          [palette_b.label, palette_b.id]
        ]
      )
    end

    it "answers all palettes when there are no associations" do
      expect(optioner.call(model)).to eq(
        [
          ["Select...", ""],
          [palette_a.label, palette_a.id],
          [palette_b.label, palette_b.id]
        ]
      )
    end
  end
end
