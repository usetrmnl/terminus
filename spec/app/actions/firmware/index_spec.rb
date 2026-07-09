# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Firmware::Index, :db do
  subject(:action) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:firmware) { Factory[:firmware, :with_attachment] }
    let(:proof) { %r(download="test.bin".+href="memory://abc123.bin") }

    before { firmware }

    it "renders default response with search results" do
      action.call Rack::MockRequest.env_for(
        "0.0",
        "HTTP_HX_TRIGGER" => "search",
        "router.params" => {query: "0.0"}
      )

      response = Rack::MockRequest.new(action).get "", params: {query: "0.0"}
      expect(response.body).to match(proof)
    end

    it "renders default response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "bogus",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No firmware found.")
    end

    it "renders htmx response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "0.0",
        "HTTP_HX_TRIGGER" => "search",
        "router.params" => {query: "0.0"}
      )

      expect(response.body.first).to match(proof)
    end

    it "renders htmx response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "bogus",
        "HTTP_HX_TRIGGER" => "search",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No firmware found.")
    end

    it "renders all devices with empty query" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: ""})
      expect(response.body.first).to match(proof)
    end

    it "renders all devices with no query" do
      response = action.call Rack::MockRequest.env_for("")
      expect(response.body.first).to match(proof)
    end
  end
end
