# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Renderers::Poll do
  subject(:renderer) { described_class.new fetcher: }

  let(:fetcher) { instance_double Terminus::Aspects::Extensions::MultiFetcher }

  describe "#call" do
    let :extension do
      Factory[
        :extension,
        kind: "poll",
        uris: ["https://test.io/test.json"],
        template: <<~CONTENT
          <h1>{{extension.label}}</h1>
          {% for item in source.data %}
            <p>{{item.label}}: {{item.description}}</p>
          {% endfor %}
        CONTENT
      ]
    end

    let(:context) { {"extension" => {"label" => "Test Label"}} }

    let :data do
      {
        "data" => [
          {
            "label" => "Test",
            "description" => "A test."
          }
        ]
      }
    end

    it "renders success for single response" do
      allow(fetcher).to receive(:call).and_return(Success({"source" => data}))

      expect(renderer.call(extension, context:)).to be_success(
        %(<h1>Test Label</h1>\n\n  <p>Test: A test.</p>\n\n)
      )
    end

    it "renders success for multiple sources" do
      extension.template.replace <<~CONTENT
        <p>{{source_1.label}}</p>
        <p>{{source_2.label}}</p>
      CONTENT

      allow(fetcher).to receive(:call).and_return(
        Success(
          {
            "source_1" => {"label" => "One"},
            "source_2" => {"label" => "Two"}
          }
        )
      )

      expect(renderer.call(extension, context:)).to be_success(<<~CONTENT)
        <p>One</p>
        <p>Two</p>
      CONTENT
    end

    it "renders empty content for failure" do
      extension.template.clear
      allow(fetcher).to receive(:call).and_return(Failure({}))

      expect(renderer.call(extension, context:)).to be_failure("")
    end
  end
end
