# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Models::Exporter, :db do
  using Refinements::Time

  subject(:exporter) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let :model do
      Factory[
        :model,
        default_palette_id: palette.id,
        name: "export",
        label: "Export",
        description: "A test.",
        css: {"classes" => {"size" => "screen--lg"}}
      ]
    end

    let(:palette) { Factory[:palette, name: "test"] }

    let :proof do
      exporter.call(model)
              .bind { Terminus::Aspects::Unzipper.new.call it }
              .value!
    end

    it "includes configuration" do
      expect(proof["configuration.yml"]).to eq(<<~CONTENT)
        ---
        version: 1.2.3
        label: Export
        name: export
        description: A test.
        kind: terminus
        mime_type: image/png
        colors: 2
        bit_depth: 1
        rotation: 0
        offset_x: 0
        offset_y: 0
        scale_factor: 1.0
        width: 800
        height: 480
        css:
          classes:
            size: screen--lg
        default_palette_name: test
      CONTENT
    end

    it "answers StringIO instance" do
      expect(exporter.call(model)).to match(Success(kind_of(StringIO)))
    end
  end
end
