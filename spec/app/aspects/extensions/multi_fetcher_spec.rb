# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::MultiFetcher do
  subject(:multi_fetcher) { described_class.new exchange_repository:, fetcher: }

  let(:fetcher) { instance_double Terminus::Aspects::Extensions::Fetcher }
  let(:exchange_repository) { instance_double Terminus::Repositories::ExtensionExchange }

  describe "#call" do
    let(:extension) { Factory.structs[:extension] }
    let(:exchange) { Factory.structs[:extension_exchange, data: "test"] }

    before do
      allow(exchange_repository).to receive(:where).with(extension_id: extension.id)
                                                   .and_return([exchange])
    end

    it "answers success with single exchange" do
      allow(fetcher).to receive(:call).with(exchange).and_return(Success(exchange))
      expect(multi_fetcher.call(extension)).to be_success("source" => "test")
    end

    it "answers success (empty hash) with single exchange fetch failure" do
      allow(fetcher).to receive(:call).with(exchange).and_return(Failure(exchange))
      expect(multi_fetcher.call(extension)).to be_success({})
    end

    it "answers success (partial hash) with multiple fetch successes and failures" do
      allow(exchange_repository).to receive(:where).with(extension_id: extension.id)
                                                   .and_return([exchange, exchange, exchange])

      allow(fetcher).to receive(:call).with(exchange)
                                      .and_return(
                                        Success(exchange),
                                        Failure(exchange),
                                        Success(exchange)
                                      )

      expect(multi_fetcher.call(extension)).to be_success(
        "source_1" => "test",
        "source_3" => "test"
      )
    end
  end
end
