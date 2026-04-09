# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Renderers::Image do
  subject(:renderer) { described_class.new exchange_repository: }

  let(:exchange_repository) { instance_double Terminus::Repositories::ExtensionExchange }

  describe "#call" do
    let :extension do
      Factory.structs[:extension, template: %(<img src="{{source_1.url}}" alt="{{extension.alt}}">)]
    end

    let(:exchange) { Factory.structs[:extension_exchange, template: "https://test.io/test.png"] }
    let(:exchanges) { [exchange] }
    let(:context) { {"extension" => {"alt" => "Image"}} }

    before do
      allow(exchange_repository).to receive(:where).with(extension_id: extension.id)
                                                   .and_return(exchanges)
    end

    it "renders template with single URI" do
      expect(renderer.call(extension, context:)).to be_success(
        %(<html><head></head><body><img src="https://test.io/test.png" alt="Image"></body></html>)
      )
    end

    it "renders template with multipe URIs" do
      allow(extension).to receive(:template).and_return(<<~CONTENT)
        <img src="{{source_1.url}}" alt="{{extension.alt}}">
        <img src="{{source_2.url}}" alt="{{extension.alt}}">
      CONTENT

      exchanges.append exchange

      expect(renderer.call(extension, context:)).to be_success(<<~CONTENT.strip)
        <html><head></head><body><img src="https://test.io/test.png" alt="Image">
        <img src="https://test.io/test.png" alt="Image">
        </body></html>
      CONTENT
    end
  end
end
