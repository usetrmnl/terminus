# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Preview::Show, :db do
  subject(:action) { described_class.new renderer: }

  let(:renderer) { instance_double Terminus::Aspects::Extensions::Renderer, call: result }
  let(:result) { "" }

  describe "#call" do
    let(:extension) { Factory[:extension, uris: ["https://one.io"]] }

    let :response do
      action.call Rack::MockRequest.env_for(
        extension.id.to_s,
        "router.params" => {
          extension_id: extension.id,
          model_id: Factory[:model].id,
          device_id: Factory[:device].id
        }
      )
    end

    context "with success" do
      let(:result) { Success "Test" }

      it "renders body" do
        expect(response.body.first).to include("Test")
      end
    end

    context "with failure" do
      let(:result) { Failure "Danger!" }

      it "renders body" do
        expect(response.body.first).to include("Danger!")
      end
    end

    context "with unknown result" do
      let(:result) { "Danger!" }

      it "renders body" do
        expect(response.body.first).to include(
          "Unable to render body for extension: #{extension.id}."
        )
      end
    end

    it "answers not found error with invalid ID" do
      response = action.call Hash.new
      expect(response.status).to eq(404)
    end
  end
end
