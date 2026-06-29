# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transforms::Variables::Key do
  subject(:transformer) { described_class.new }

  describe "#call" do
    it "answers data as source" do
      expect(transformer.call(+"data")).to eq("source_1")
    end

    it "answers TRMNL plugin instance name as extension label" do
      expect(transformer.call(+"trmnl.plugin_settings.instance_name")).to eq("extension.label")
    end

    it "answers TRMNL plugin field values as extension values" do
      expect(transformer.call(+"trmnl.plugin_settings.custom_fields_values")).to eq(
        "extension.values"
      )
    end

    it "answers TRMNL plugin field as extension fields" do
      expect(transformer.call(+"trmnl.plugin_settings.custom_fields[0]")).to eq(
        "extension.fields[0]"
      )
    end

    it "answers RSS with source prefix" do
      expect(transformer.call(+"rss.channel.item[0]")).to eq("source_1.rss.channel.item[0]")
    end
  end
end
