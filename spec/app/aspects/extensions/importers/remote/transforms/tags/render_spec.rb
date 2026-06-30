# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transforms::Tags::Render do
  subject(:transformer) { described_class.new }

  describe "#call" do
    it "answers remaped TRMNL pair" do
      content = +%(render "main", trmnl: trmnl, rss: rss)

      expect(transformer.call(content)).to eq(
        %(render "main", extension: extension, source_1: source_1.rss)
      )
    end

    it "answers original content when pairs don't map" do
      content = +%(render "main", text: example)
      expect(transformer.call(content)).to eq(content)
    end

    it "answers original content when name doesn't match" do
      content = +%(process "main", trmnl: trmnl, rss: rss)
      expect(transformer.call(content)).to eq(content)
    end
  end
end
