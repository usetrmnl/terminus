# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::API::Extensions::Build::Create, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension] }

    let :response do
      action.call Rack::MockRequest.env_for(
        extension.id.to_s,
        "router.params" => {extension_id: extension.id}
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

    it "answers enqueued payload" do
      expect(JSON(response.body.first, symbolize_names: true)).to eq(
        data: {id: extension.id, enqueued: true}
      )
    end

    context "with unknown extension" do
      let :response do
        action.call Rack::MockRequest.env_for("666", "router.params" => {extension_id: 666})
      end

      it "answers not found" do
        expect(JSON(response.body.first, symbolize_names: true)).to include(status: 404)
      end
    end
  end
end
