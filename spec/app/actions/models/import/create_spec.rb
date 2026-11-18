# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Models::Import::Create, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:exporter) { Terminus::Aspects::Models::Exporter.new }
    let(:model) { Factory.structs[:model, name: "test", label: "Test", colors: 2, bit_depth: 1] }

    it "renders errors when invalid" do
      allow(model).to receive(:export_attributes).and_return({})

      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {
          model: {
            attachment: {
              name: "test",
              type: "application/zip",
              head: "test",
              filename: "test.zip",
              tempfile: exporter.call(model).value!
            }
          }
        }
      )

      expect(response.flash.inspect).to include("label is missing")
    end

    it "flashes success when valid" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {
          model: {
            attachment: {
              name: "test",
              type: "application/zip",
              head: "test",
              filename: "test.zip",
              tempfile: exporter.call(model).value!
            }
          }
        }
      )

      expect(response.flash.inspect).to include("Model imported!")
    end

    it "answers unprocessable content when parameters are missing" do
      response = Rack::MockRequest.new(action).post("")
      expect(response.status).to eq(422)
    end
  end
end
