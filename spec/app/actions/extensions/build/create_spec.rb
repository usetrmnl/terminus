# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Build::Create, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension] }

    let :response do
      action.call Rack::MockRequest.env_for(
        extension.id.to_s,
        "router.params" => {id: extension.id}
      )
    end

    it "enqueues job" do
      Sidekiq::Testing.fake! do
        response

        expect(Terminus::Jobs::Batches::Extension.jobs).to contain_exactly(
          hash_including("args" => [extension.id])
        )
      end
    end

    it "answers accepted status" do
      expect(response.status).to eq(202)
    end
  end
end
