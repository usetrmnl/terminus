# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transforms::Variables::Index do
  subject(:transformer) { described_class.new }

  describe "#call" do
    it "answers" do
      expect(transformer.call(+"IDX_0")).to eq("source_1")
    end
  end
end
