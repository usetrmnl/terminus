# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exchanges::Refresher, :db do
  subject(:refresher) { described_class.new client: }

  let(:client) { instance_double Terminus::Aspects::Extensions::Fetchers::Client }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    it "answers success with data and no errors" do
      allow(client).to receive(:call).and_return(
        Success(
          Terminus::Aspects::Extensions::Fetchers::Response[data: "test"]
        )
      )

      expect(refresher.call(exchange)).to match(
        Success(having_attributes(data: {"source_1" => "test"}))
      )
    end

    it "answers success with errors only" do
      allow(client).to receive(:call).and_return(
        Failure(
          Terminus::Aspects::Extensions::Fetchers::Response[errors: "Danger!"]
        )
      )

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {},
            errors: {"source_1" => "Danger!"}
          )
        )
      )
    end

    it "answers success that retains previous data while updating error" do
      exchange = Factory[:extension_exchange, data: {"source_1" => "initial"}]

      allow(client).to receive(:call).and_return(
        Failure(Terminus::Aspects::Extensions::Fetchers::Response[errors: "Danger!"])
      )

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {"source_1" => "initial"},
            errors: {"source_1" => "Danger!"}
          )
        )
      )
    end

    it "answers success with mixed data and errors" do
      exchange = Factory[:extension_exchange, template: "https://one.io\nhttps://two.io"]

      allow(client).to receive(:call).and_return(
        Failure(Terminus::Aspects::Extensions::Fetchers::Response[errors: "Danger!"]),
        Success(Terminus::Aspects::Extensions::Fetchers::Response[data: "pass"])
      )

      expect(refresher.call(exchange)).to match(
        Success(
          having_attributes(
            data: {"source_2" => "pass"},
            errors: {"source_1" => "Danger!"}
          )
        )
      )
    end

    it "answers success with fetch error" do
      allow(client).to receive(:call).and_return(:bogus)

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
      allow(client).to receive(:call).and_return(
        Success(Terminus::Aspects::Extensions::Fetchers::Response[data: "test"])
      )

      expect(refresher.call(exchange)).to match(
        Success(kind_of(Terminus::Structs::ExtensionExchange))
      )
    end

    it "answers failure when extension can't be found" do
      allow(exchange).to receive(:extension_id).and_return 666
      expect(refresher.call(exchange)).to be_failure("Unable to find extension by ID: 666.")
    end
  end
end
