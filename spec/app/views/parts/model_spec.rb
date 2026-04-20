# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Model, :db do
  subject(:part) { described_class.new value: model, rendering: Terminus::View.new.rendering }

  let(:model) { Factory.structs[:model] }

  let :view do
    Class.new Hanami::View do
      config.paths = [Hanami.app.root.join("app/templates")]
      config.template = "n/a"
    end
  end

  describe "#allowd_palettes", :db do
    let(:model) { Factory[:model] }
    let(:palette) { Factory[:palette, name: "test"] }
    let(:association) { Factory[:model_palette, model_id: model.id, palette_id: palette.id] }

    it "answers names when associations exist" do
      association
      expect(part.allowed_palettes).to eq("test")
    end

    it "answers all with no associations" do
      expect(part.allowed_palettes).to eq("All")
    end
  end

  describe "#default_palette_name", :db do
    context "when default exists" do
      let :model do
        palette = Factory[:palette, name: "test"]
        model = Factory[:model, default_palette_id: palette.id]
        Terminus::Repositories::Model.new.find model.id
      end

      it "answers name" do
        expect(part.default_palette_name).to eq("test")
      end
    end

    it "answers none when default doesn't exist" do
      expect(part.default_palette_name).to eq("None")
    end
  end

  describe "#formatted_css" do
    it "answers empty string when attributes are empty" do
      expect(part.formatted_css).to eq("")
    end

    it "answers formatted code when attributes exist" do
      allow(model).to receive(:css).and_return(
        {
          classes: {
            size: "screen--lg",
            device: "screen--v2"
          }
        }
      )

      expect(part.formatted_css).to eq(<<~JSON.strip)
        {
          "classes": {
            "size": "screen--lg",
            "device": "screen--v2"
          }
        }
      JSON
    end
  end

  describe "#dimensions" do
    it "answers default dimensions" do
      expect(part.dimensions).to eq("800x480")
    end

    context "with custom dimensions" do
      let(:model) { Factory.structs[:model, width: 400, height: 240] }

      it "answers custom width and height" do
        expect(part.dimensions).to eq("400x240")
      end
    end
  end

  describe "#kind_label" do
    it "answers capitalized label" do
      expect(part.kind_label).to eq("Terminus")
    end

    context "with byod" do
      let(:model) { Factory.structs[:model, kind: "byod"] }

      it "answers upcase" do
        expect(part.kind_label).to eq("BYOD")
      end
    end

    context "with trmnl" do
      let(:model) { Factory.structs[:model, kind: "trmnl"] }

      it "answers upcase" do
        expect(part.kind_label).to eq("TRMNL")
      end
    end
  end
end
