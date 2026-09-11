# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Index, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension, label: "Test", name: "test"] }

    it "renders default response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {query: extension.label}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end

    it "renders default response with no results" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "bogus"})

      expect(response.body.first).to include("No extensions found.")
    end

    it "renders htmx response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: extension.label}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end

    it "renders htmx response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No extensions found.")
    end

    it "renders all extensions with no query" do
      extension
      response = action.call Rack::MockRequest.env_for("", "HTTP_HX_SOURCE" => "input#search")

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end
  end
end
