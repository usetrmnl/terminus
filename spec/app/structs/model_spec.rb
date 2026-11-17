# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::Model do
  subject(:model) { Factory.structs[:model, **attributes] }

  let :attributes do
    {
      name: "test",
      label: "Test",
      bit_depth: 4,
      css: {
        "classes" => {"size" => "screen--lg", "density" => "screen--density-2x"},
        "variables" => [
          %w[--screen-w 1040px],
          %w[--screen-h 780px],
          %w[--pixel-ratio 1.8]
        ]
      }
    }
  end

  describe "#css_classes" do
    it "answers classes with full information" do
      expect(model.css_classes).to eq(
        %w[screen screen--test screen--4bit screen--landscape screen--lg screen--density-2x]
      )
    end

    it "answers classes with missing values" do
      attributes.merge! name: nil, bit_depth: nil

      expect(model.css_classes).to eq(
        %w[screen screen-- screen--bit screen--landscape screen--lg screen--density-2x]
      )
    end

    it "answers classes without model classes" do
      attributes[:css].clear
      expect(model.css_classes).to eq(%w[screen screen--test screen--4bit screen--landscape])
    end
  end

  describe "#css_variables" do
    it "answers variables" do
      expect(model.css_variables).to eq(
        [
          "--screen-w: 1040px;",
          "--screen-h: 780px;",
          "--pixel-ratio: 1.8;"
        ]
      )
    end
  end

  describe "#export_attributes" do
    it "answers attributes" do
      expect(model.export_attributes).to eq(
        label: "Test",
        name: "test",
        description: nil,
        kind: "terminus",
        mime_type: "image/png",
        colors: nil,
        bit_depth: 4,
        rotation: 0,
        offset_x: 0,
        offset_y: 0,
        scale_factor: 1,
        width: 800,
        height: 480,
        css: {
          "classes" => {
            "size" => "screen--lg",
            "density" => "screen--density-2x"
          },
          "variables" => [
            ["--screen-w", "1040px"],
            ["--screen-h", "780px"],
            ["--pixel-ratio", "1.8"]
          ]
        }
      )
    end
  end

  describe "#orientation" do
    it "answers landscape when rotation is zero" do
      expect(model.orientation).to eq("landscape")
    end

    it "answers portrait when rotation is non-zero" do
      model = Factory.structs[:model, rotation: 90]
      expect(model.orientation).to eq("portrait")
    end
  end
end
