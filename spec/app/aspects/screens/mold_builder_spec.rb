# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::MoldBuilder, :db do
  subject(:builder) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    it "answers mold with palette color codes" do
      palette = Factory[
        :palette,
        name: "color-4bwry",
        grays: 2,
        colors: %w[#000000 #FF0000 #FFFFFF #FFFF00]
      ]

      model = Factory[:model, bit_depth: 1, colors: 2, default_palette_id: palette.id]

      expect(builder.call(model_id: model.id, name: "test", label: "Test")).to be_success(
        Terminus::Aspects::Screens::Mold[
          model_id: model.id,
          name: "test",
          label: "Test",
          bit_depth: 1,
          grays: 2,
          colors: 2,
          color_codes: %w[#000000 #FF0000 #FFFFFF #FFFF00],
          mime_type: "image/png",
          rotation: 0,
          offset_x: 0,
          offset_y: 0,
          width: 800,
          height: 480
        ]
      )
    end

    it "answers mold with palette fallbacks when default palette isn't found" do
      model = Factory[:model, bit_depth: 1, colors: 2]

      expect(builder.call(model_id: model.id, name: "test", label: "Test")).to be_success(
        Terminus::Aspects::Screens::Mold[
          model_id: model.id,
          name: "test",
          label: "Test",
          bit_depth: 1,
          grays: 0,
          colors: 2,
          color_codes: [],
          mime_type: "image/png",
          rotation: 0,
          offset_x: 0,
          offset_y: 0,
          width: 800,
          height: 480
        ]
      )
    end

    it "logs debug information" do
      model = Factory[:model, bit_depth: 4]
      builder.call model_id: model.id, name: "test", label: "Test"

      expect(logger.reread).to match(/DEBUG.+Screen mold built.+bit_depth.+4/)
    end
  end
end
