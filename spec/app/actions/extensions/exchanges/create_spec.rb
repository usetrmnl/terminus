# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Exchanges::Create, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension] }

    let :response do
      action.call Rack::MockRequest.env_for(
        extension.id.to_s,
        "router.params" => {
          extension_id: extension.id,
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
          hash_including("args" => [kind_of(Integer)])
        )
      end
    end
  end
end
