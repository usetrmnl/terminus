# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Poll::Show, :db do
  subject(:action) { described_class.new fetcher: }

  let(:fetcher) { instance_double Terminus::Aspects::Extensions::MultiFetcher, call: result }

  describe "#call" do
    let(:exchange) { Factory[:extension_exchange] }

    context "with success (non-image kind)" do
      let :result do
        Success({"source_1" => {"data" => [{"name" => "test"}]}})
      end

      it "renders data" do
        response = action.call Rack::MockRequest.env_for(
          exchange.extension_id.to_s,
          "router.params" => {extension_id: exchange.extension_id}
        )

        expect(response.body.first).to match(/name.+test/)
      end
    end

    context "with failure" do
      let(:result) { Failure "Danger!" }

      it "renders error" do
        response = action.call Rack::MockRequest.env_for(
          exchange.extension_id.to_s,
          "router.params" => {extension_id: exchange.extension_id}
        )

        expect(response.body.first).to include(<<~HTML)
          <textarea class="bit-editor" data-mode="read" data-language="json">
          Unable to render content. Please check your exchanges.</textarea>
        HTML
      end
    end

    context "with invalid ID" do
      let(:result) { Success({}) }

      it "answers not found error with invalid ID" do
        response = action.call Hash.new
        expect(response.status).to eq(404)
      end
    end
  end
end
