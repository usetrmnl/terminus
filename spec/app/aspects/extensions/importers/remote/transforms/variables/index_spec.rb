# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transforms::Variables::Index do
  subject(:transformer) { described_class.new }

  describe "#call" do
    it "answers index as source" do
      expect(transformer.call(+"IDX_0")).to eq("source_1")
    end

    it "answers multiple indexes as sources" do
      content = <<~CONTENT.strip
        IDX_0
        IDX_1
        IDX_2
      CONTENT

      expect(transformer.call(+content)).to eq(<<~CONTENT.strip)
        source_1
        source_2
        source_3
      CONTENT
    end
  end
end
