# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Exchanges::Update, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    let :response do
      action.call Rack::MockRequest.env_for(
        exchange.id.to_s,
        "router.params" => {
          extension_id: exchange.extension_id,
          id: exchange.id,
          exchange: {
            template: "test"
          }
        }
      )
    end

    it "enqueues job" do
      Sidekiq::Testing.fake! do
        response

        expect(Terminus::Jobs::Extensions::ExchangeRefresh.jobs).to contain_exactly(
          hash_including("args" => [exchange.id])
        )
      end
    end
  end
end
