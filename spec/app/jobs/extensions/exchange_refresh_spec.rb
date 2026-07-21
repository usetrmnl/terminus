# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Extensions::ExchangeRefresh, :db do
  subject(:job) { described_class.new refresher: }

  include_context "with application dependencies"

  let(:refresher) { instance_spy Terminus::Aspects::Extensions::Exchanges::Refresher }

  describe "#perform" do
    let(:exchange) { Factory[:extension_exchange] }

    it "answers success when extension and model exist" do
      job.perform exchange.id
      expect(refresher).to have_received(:call).with(kind_of(Terminus::Structs::ExtensionExchange))
    end

    it "logs info when enqueued" do
      job.perform exchange.id
      expect(logger.reread).to match(/INFO.+Enqueued refresh for exchange: #{exchange.id}\./)
    end

    it "logs error when exchange can't be found" do
      job.perform 666
      expect(logger.reread).to match(/ERROR.+Unable to find exchange ID: 666\./)
    end
  end
end
