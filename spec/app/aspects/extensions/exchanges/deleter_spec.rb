# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exchanges::Deleter, :db do
  subject(:deleter) { described_class.new }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange, template: "<h1>Test</h1>"] }
    let(:attributes) { {extension_id: exchange.extension_id, id: exchange.id} }

    let :validator do
      Dry::Schema.Params do
        required(:extension_id).filled :integer
        required(:id).filled :integer
      end
    end

    it "deletes exchange" do
      expect(deleter.call(attributes, validator:).value!).to have_attributes(
        template: "<h1>Test</h1>"
      )
    end

    it "answers exchange" do
      expect(deleter.call(attributes, validator:)).to match(
        Success(Terminus::Structs::ExtensionExchange)
      )
    end

    it "answers failure when not found by extension ID" do
      attributes[:extension_id] = 666

      expect(deleter.call(attributes, validator:)).to be_failure(
        "Unable to find exchange by extension ID (666) or ID (#{exchange.id})."
      )
    end

    it "answers failure when not found by ID" do
      attributes[:id] = 666

      expect(deleter.call(attributes, validator:)).to be_failure(
        "Unable to find exchange by extension ID (#{exchange.extension_id}) or ID (666)."
      )
    end
  end
end
