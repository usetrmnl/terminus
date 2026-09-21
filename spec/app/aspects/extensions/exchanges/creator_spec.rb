# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exchanges::Creator, :db do
  subject(:creator) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension] }
    let(:attributes) { {extension_id: extension.id, exchange: {template: "<h1>Test</h1>"}} }

    let :validator do
      Dry::Schema.Params do
        required(:extension_id).filled :integer

        required(:exchange).filled :hash do
          required(:template).filled :string
        end
      end
    end

    it "creates exchange" do
      expect(creator.call(attributes, validator:).value!).to have_attributes(
        extension_id: extension.id,
        template: "<h1>Test</h1>"
      )
    end

    it "schedules job" do
      job = class_spy Terminus::Jobs::Extensions::ExchangeRefresh
      creator = described_class.new(job:)
      exchange = creator.call(attributes, validator:).value!

      expect(job).to have_received(:perform_async).with(exchange.id)
    end

    it "answers exchange" do
      expect(creator.call(attributes, validator:)).to match(
        Success(Terminus::Structs::ExtensionExchange)
      )
    end

    it "answers failure with invalid attributes" do
      attributes[:exchange].delete :template

      expect(creator.call(attributes, validator:).failure.errors.to_h).to eq(
        exchange: ["must be filled"]
      )
    end
  end
end
