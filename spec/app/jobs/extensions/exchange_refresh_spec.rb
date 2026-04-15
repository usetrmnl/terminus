# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Extensions::ExchangeRefresh, :db do
  subject(:job) { described_class.new refresher: }

  let(:refresher) { instance_spy Terminus::Aspects::Extensions::Exchanges::Refresher }

  describe "#perform" do
    it "answers success when extension and model exist" do
      exchange = Factory[:extension_exchange]
      job.perform exchange.id

      expect(refresher).to have_received(:call).with(kind_of(Terminus::Structs::ExtensionExchange))
    end

    it "answers failure when extension can't be found" do
      expect(job.perform(13)).to be_failure("Unable to find exchange ID: 13.")
    end
  end
end
