# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Exchanges::Update, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    let :response do
      action.call Rack::MockRequest.env_for(exchange.id.to_s, "router.params" => parameters)
    end

    let :parameters do
      {
        extension_id: exchange.extension_id,
        id: exchange.id,
        exchange: {
          template: "test"
        }
      }
    end

    it "enqueues job" do
      Sidekiq::Testing.fake! do
        response

        expect(Terminus::Jobs::Extensions::ExchangeRefresh.jobs).to contain_exactly(
          hash_including("args" => [exchange.id])
        )
      end
    end

    it "errors when template is not filled" do
      parameters[:exchange][:template] = nil
      expect(response.body.to_s).to include("must be filled")
    end

    it "answers unprocessable entity for unknown ID" do
      response = action.call extension_id: exchange.extension_id,
                             id: 666,
                             exchange: {template: "test"}
      expect(response.status).to eq(422)
    end
  end
end
