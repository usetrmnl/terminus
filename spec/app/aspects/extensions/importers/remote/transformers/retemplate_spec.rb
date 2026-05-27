# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Retemplate do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let(:buffer) { +"" }

    it "answers success indexed sources" do
      template = <<~CONTENT
        {{ IDX_0 }}
        {{ IDX_1 }}
        {{ IDX_2 }}
      CONTENT

      transformer.call template, buffer

      expect(buffer).to eq(<<~CONTENT)
        {{ source_1 }}
        {{ source_2 }}
        {{ source_3 }}
      CONTENT
    end

    it "answers identical copy" do
      original = SPEC_ROOT.join("support/fixtures/test.html.liquid").read
      transformer.call original, buffer

      expect(buffer).to eq(original)
    end
  end
end
