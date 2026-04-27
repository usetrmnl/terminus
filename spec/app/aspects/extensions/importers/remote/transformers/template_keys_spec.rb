# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::TemplateKeys do
  subject(:transformer) { described_class.new }

  describe "#call" do
    context "with source indexes" do
      let :content do
        <<~CONTENT
          <p>{{IDX_0}}</p>
          <p>{{IDX_1}}</p>
          <p>{{IDX_2}}</p>
        CONTENT
      end

      let :proof do
        <<~CONTENT
          <p>{{source_1}}</p>
          <p>{{source_2}}</p>
          <p>{{source_3}}</p>
        CONTENT
      end

      it "answers success indexed sources" do
        expect(transformer.call(content)).to be_success(proof)
      end
    end

    context "with special keys" do
      let :content do
        <<~CONTENT
          <p>{{ rss.channel.item[0] }}</p>
          <p>{{ source_1.data }}</p>
          <p>{{ trmnl.plugin_settings.instance_name }}</p>
          <p>{{ trmnl.plugin_settings.custom_fields_values.test }}</p>
          <p>{{ trmnl.plugin_settings.custom_fields[0].name }}</p>
        CONTENT
      end

      let :proof do
        <<~CONTENT
          <p>{{ source_1.rss.channel.item[0] }}</p>
          <p>{{ source_1 }}</p>
          <p>{{ extension.label }}</p>
          <p>{{ extension.values.test }}</p>
          <p>{{ extension.fields[0].name }}</p>
        CONTENT
      end

      it "answers success indexed sources" do
        expect(transformer.call(content)).to be_success(proof)
      end
    end
  end
end
