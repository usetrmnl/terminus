# frozen_string_literal: true

require "hanami_helper"

# rubocop:todo Layout/LineLength
RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Templates::Variablizer do
  subject(:transformer) { described_class.new }

  let(:node) { Liquid::Variable.new markup, Liquid::ParseContext.new({}) }

  describe "#call" do
    let(:markup) { "{{IDX_0}}" }

    it "answers" do
      result = transformer.call node
      expect(result).to eq("{{ IDX_0 }}")
    end
  end
end
# rubocop:enable Layout/LineLength
