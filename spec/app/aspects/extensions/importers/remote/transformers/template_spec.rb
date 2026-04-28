# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Template do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let(:archive) { {full: content, shared: %({% assign shared = "Test" %})} }

    context "with URI indexes" do
      let :content do
        <<~CONTENT
          {{ IDX_0 }}
          {{ IDX_1 }}
          {{ IDX_2 }}
        CONTENT
      end

      let :proof do
        {
          template: <<~CONTENT
            {% assign shared = "Test" %}

            <div class="{{extension.css_classes}}">
              <div class="view view--full">
                {{ source_1 }}
            {{ source_2 }}
            {{ source_3 }}

              </div>
            </div>
          CONTENT
        }
      end

      it "answers success indexed sources" do
        expect(transformer.call({}, archive)).to be_success(proof)
      end
    end

    context "with special keys" do
      let :content do
        <<~CONTENT
          {{ rss.channel.item[0] }}
          {{ source_1.data }}
          {{ trmnl.plugin_settings.instance_name }}
          {{ trmnl.plugin_settings.custom_fields_values.test }}
          {{ trmnl.plugin_settings.custom_fields[0].name }}
        CONTENT
      end

      let :proof do
        {
          template: <<~CONTENT
            {% assign shared = "Test" %}

            <div class="{{extension.css_classes}}">
              <div class="view view--full">
                {{ source_1.rss.channel.item[0] }}
            {{ source_1.data }}
            {{ extension.label }}
            {{ extension.values.test }}
            {{ extension.fields[0].name }}

              </div>
            </div>
          CONTENT
        }
      end

      it "answers success indexed sources" do
        expect(transformer.call({}, archive)).to be_success(proof)
      end
    end

    context "without shared content" do
      let(:content) { "<p>Test</p>" }

      it "answers success indexed sources" do
        archive.delete :shared

        expect(transformer.call({}, archive)).to be_success(
          template: <<~CONTENT
            <div class="{{extension.css_classes}}">
              <div class="view view--full">
                <p>Test</p>
              </div>
            </div>
          CONTENT
        )
      end
    end
  end
end
