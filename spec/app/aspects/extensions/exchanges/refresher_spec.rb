# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exchanges::Refresher, :db do
  subject(:refresher) { described_class.new fetcher: }

  let(:fetcher) { instance_double Terminus::Aspects::Extensions::Fetchers::Sole }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    it "answers success with data and no errors" do
      allow(fetcher).to receive(:call).and_return(Success(data: "test"))

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {"source_1" => "test"},
            errors: {}
          )
        )
      )
    end

    it "answers success with errors only" do
      allow(fetcher).to receive(:call).and_return(Failure(error: "Danger!"))

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {},
            errors: {"source_1" => "Danger!"}
          )
        )
      )
    end

    it "answers success with mixed data and errors" do
      exchange = Factory[:extension_exchange, template: "https://one.io\nhttps://two.io"]

      allow(fetcher).to receive(:call).and_return(Failure(error: "Danger!"), Success(data: "pass"))

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {"source_2" => "pass"},
            errors: {"source_1" => "Danger!"}
          )
        )
      )
    end

    it "answers success with fetech error" do
      allow(fetcher).to receive(:call).and_return(:bogus)

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {},
            errors: {"source_1" => "Unable to fetch, invalid result."}
          )
        )
      )
    end

    it "answers an exchange" do
      allow(fetcher).to receive(:call).and_return(Success(data: "test"))

      expect(refresher.call(exchange)).to match(
        Success(kind_of(Terminus::Structs::ExtensionExchange))
      )
    end

    it "answers failure when extension can't be found" do
      allow(exchange).to receive(:extension_id).and_return 13
      expect(refresher.call(exchange)).to be_failure("Unable to find extension by ID: 13.")
    end
  end
end
