# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Renderers::Poll do
  subject(:renderer) { described_class.new refresher: }

  let(:refresher) { instance_spy Terminus::Aspects::Extensions::Exchanges::Refresher }

  describe "#call" do
    let :extension do
      Factory[
        :extension,
        kind: "poll",
        uris: ["https://test.io/test.json"],
        template: <<~CONTENT
          <h1>{{extension.label}}</h1>
          {% for item in source_1 %}
            <p>{{item.label}}: {{item.description}}</p>
          {% endfor %}
        CONTENT
      ]
    end

    let(:exchange) { Factory[:extension_exchange, extension_id: extension.id, data:] }

    let :data do
      {
        "source_1" => [
          {
            "label" => "Test",
            "description" => "A test."
          }
        ]
      }
    end

    let(:context) { {"extension" => {"label" => "Test Label"}} }

    it "calls refresher" do
      exchange
      renderer.call(extension, context:)

      expect(refresher).to have_received(:call).with(kind_of(Terminus::Structs::ExtensionExchange))
    end

    it "renders success for single source" do
      exchange

      expect(renderer.call(extension, context:)).to be_success(<<~CONTENT.strip)
        <html><head></head><body><h1>Test Label</h1>

          <p>Test: A test.</p>

        </body></html>
      CONTENT
    end

    it "renders success for multiple sources" do
      extension.template.replace <<~CONTENT
        <p>{{source_1.label}}</p>
        <p>{{source_2.label}}</p>
      CONTENT

      data.merge! "source_1" => {"label" => "One"}, "source_2" => {"label" => "Two"}
      exchange

      expect(renderer.call(extension, context:)).to be_success(<<~CONTENT.strip)
        <html><head></head><body><p>One</p>
        <p>Two</p>
        </body></html>
      CONTENT
    end

    it "renders empty content without exchanges" do
      extension.template.clear

      expect(renderer.call(extension, context:)).to be_success(
        "<html><head></head><body></body></html>"
      )
    end
  end
end
