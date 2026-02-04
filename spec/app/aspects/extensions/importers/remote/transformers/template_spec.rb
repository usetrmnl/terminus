# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Template do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let(:archive) { {full: content, shared: %({% assign shared = "Test" %})} }

    context "with URI indexes" do
      let :content do
        <<~CONTENT
          <p>{{IDX_0}}</p>
          <p>{{IDX_1}}</p>
          <p>{{IDX_2}}</p>
        CONTENT
      end

      let :proof do
        {
          template: <<~CONTENT
            {% assign shared = "Test" %}

            <div class="{{extension.css_classes}}">
              <p>{{source_1}}</p>
            <p>{{source_2}}</p>
            <p>{{source_3}}</p>

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
          <p>{{ source_1.data }}</p>
          <p>{{ trmnl.plugin_settings.custom_fields_values.test }}</p>
          <p>{{ trmnl.plugin_settings.custom_fields[0].name }}</p>
        CONTENT
      end

      let :proof do
        {
          template: <<~CONTENT
            {% assign shared = "Test" %}

            <div class="{{extension.css_classes}}">
              <p>{{ source_1 }}</p>
            <p>{{ extension.values.test }}</p>
            <p>{{ extension.fields[0].name }}</p>

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
              <p>Test</p>
            </div>
          CONTENT
        )
      end
    end
  end
end
