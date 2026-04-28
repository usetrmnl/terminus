# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::TemplateKeys do
  subject(:transformer) { described_class.new }

  describe "#call" do
    context "with source indexes" do
      let :content do
        <<~CONTENT
          {{IDX_0}}
          {{IDX_1}}
          {{IDX_2}}
        CONTENT
      end

      let :proof do
        <<~CONTENT
          {{source_1}}
          {{source_2}}
          {{source_3}}
        CONTENT
      end

      it "answers success indexed sources" do
        expect(transformer.call(content)).to be_success(proof)
      end
    end

    context "with special keys" do
      let :content do
        <<~CONTENT
          {{ data }}
          {{ rss.channel.item[0] }}
          {{ trmnl.plugin_settings.instance_name }}
          {{ trmnl.plugin_settings.custom_fields_values.test }}
          {{ trmnl.plugin_settings.custom_fields[0].name }}
        CONTENT
      end

      let :proof do
        <<~CONTENT
          {{ source_1.data }}
          {{ source_1.rss.channel.item[0] }}
          {{ extension.label }}
          {{ extension.values.test }}
          {{ extension.fields[0].name }}
        CONTENT
      end

      it "answers success indexed sources" do
        expect(transformer.call(content)).to be_success(proof)
      end
    end

    it "prefixes bare key" do
      expect(transformer.call("{{ name }}")).to be_success("{{ source_1.name }}")
    end

    it "prefixes bare key with filter" do
      expect(transformer.call("{{ name | capitalize }}")).to be_success(
        "{{ source_1.name | capitalize }}"
      )
    end

    it "prefixes bare RSS key" do
      expect(transformer.call("{{ rss.channel.item[0] }}")).to be_success(
        "{{ source_1.rss.channel.item[0] }}"
      )
    end

    it "renames plugin instance name" do
      expect(transformer.call("{{ trmnl.plugin_settings.instance_name }}")).to be_success(
        "{{ extension.label }}"
      )
    end

    it "renames plugin values" do
      content = "{{ trmnl.plugin_settings.custom_fields_values.test }}"

      expect(transformer.call(content)).to be_success("{{ extension.values.test }}")
    end

    it "renames plugin field name" do
      content = "{{ trmnl.plugin_settings.custom_fields[0].name }}"

      expect(transformer.call(content)).to be_success("{{ extension.fields[0].name }}")
    end
  end
end
