# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exchanges::Updater, :db do
  subject(:updater) { described_class.new }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    let :attributes do
      {extension_id: exchange.extension_id, id: exchange.id, exchange: {template: "<h1>Test</h1>"}}
    end

    let :validator do
      Dry::Schema.Params do
        required(:extension_id).filled :integer
        required(:id).filled :integer

        required(:exchange).filled :hash do
          required(:template).filled :string
        end
      end
    end

    it "updates exchange" do
      expect(updater.call(attributes, validator:).value!).to have_attributes(
        extension_id: exchange.extension_id,
        template: "<h1>Test</h1>"
      )
    end

    it "schedules job" do
      job = class_spy Terminus::Jobs::Extensions::ExchangeRefresh
      updater = described_class.new(job:)
      exchange = updater.call(attributes, validator:).value!

      expect(job).to have_received(:perform_async).with(exchange.id)
    end

    it "answers exchange" do
      expect(updater.call(attributes, validator:)).to match(
        Success(Terminus::Structs::ExtensionExchange)
      )
    end

    it "answers failure when not found by extension ID" do
      attributes[:extension_id] = 666

      expect(updater.call(attributes, validator:)).to be_failure(
        "Unable to find exchange by extension ID (666) or ID (#{exchange.id})."
      )
    end

    it "answers failure when not found by ID" do
      attributes[:id] = 666

      expect(updater.call(attributes, validator:)).to be_failure(
        "Unable to find exchange by extension ID (#{exchange.extension_id}) or ID (666)."
      )
    end

    it "answers failure with invalid attributes" do
      attributes[:exchange].delete :template

      expect(updater.call(attributes, validator:).failure.errors.to_h).to eq(
        exchange: ["must be filled"]
      )
    end
  end
end
