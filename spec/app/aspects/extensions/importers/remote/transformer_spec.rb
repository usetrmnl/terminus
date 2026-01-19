# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformer do
  subject(:transformer) { described_class.new extractor: }

  let(:extractor) { instance_double Terminus::Aspects::Extensions::Importers::Remote::Extractor }

  describe "#call" do
    let :archive do
      {
        settings: attributes.to_yaml,
        full: "<h1>Test</h1>",
        shared: %({% assign shared = "Test" %})
      }
    end

    let :attributes do
      {
        custom_fields: [
          {
            "keyname" => "test",
            "field_type" => "url",
            "name" => "https://test.io"
          }
        ],
        dark_mode: "yes",
        name: "Test",
        polling_body: %({"sort":"name", "limit": 10}),
        polling_headers: "accept=application/json&content-type=application/json",
        polling_url: "https://test.io/test",
        polling_verb: "get",
        refresh_interval: 100,
        static_data: %({"handle":"test", "email": "test@test.io"}),
        strategy: "polling"
      }
    end

    let :proof do
      {
        name: "test",
        label: "Test",
        description: "Imported from TRMNL.",
        kind: "poll",
        headers: {
          "accept" => "application/json",
          "content-type" => "application/json"
        },
        verb: "get",
        pollers: ["https://test.io/test"],
        body: {
          "sort" => "name",
          "limit" => 10
        },
        fields: [
          {
            "keyname" => "test",
            "field_type" => "url",
            "name" => "https://test.io"
          }
        ],
        interval: 1,
        unit: "minute",
        template: <<~CONTENT
          {% assign shared = "Test" %}

          <div class="{{extension.css_classes}}">
            <div class="view view--full">
              <h1>Test</h1>
            </div>
          </div>
        CONTENT
      }
    end

    it "imports polling plugin" do
      allow(extractor).to receive(:call).and_return Success(archive)
      expect(transformer.call(1)).to be_success(proof)
    end

    it "imports static plugin" do
      attributes[:strategy] = "static"
      proof.merge! kind: "static", body: {"handle" => "test", "email" => "test@test.io"}

      allow(extractor).to receive(:call).and_return Success(archive)
      expect(transformer.call(1)).to be_success(proof)
    end

    it "transforms template indexes" do
      archive[:full] = <<~CONTENT.strip
        <p>{{IDX_0}}</p>
        <p>{{IDX_1}}</p>
        <p>{{IDX_2}}</p>
      CONTENT

      proof[:template] = <<~CONTENT
        {% assign shared = "Test" %}

        <div class="{{extension.css_classes}}">
          <div class="view view--full">
            <p>{{source_1}}</p>
        <p>{{source_2}}</p>
        <p>{{source_3}}</p>
          </div>
        </div>
      CONTENT

      allow(extractor).to receive(:call).and_return Success(archive)
      expect(transformer.call(1)).to be_success(proof)
    end

    it "fails with unknown kind" do
      attributes[:strategy] = "bogus"
      allow(extractor).to receive(:call).and_return Success(archive)

      expect(transformer.call(1)).to be_failure(
        "Unsupported kind: bogus. Use: polling or static."
      )
    end
  end
end
