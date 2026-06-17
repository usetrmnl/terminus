# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Designs::Index, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:template) { Factory[:screen_template, label: "Test", name: "test"] }

    before { template }

    it "renders default response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {query: template.label}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end

    it "renders default response with no results" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "bogus"})
      expect(response.body.first).to include("No templates found.")
    end

    it "renders htmx response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_TRIGGER" => "search",
        "router.params" => {query: template.label}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end

    it "renders htmx response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_TRIGGER" => "search",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No templates found.")
    end

    it "renders all screens with no query" do
      response = action.call Rack::MockRequest.env_for("", "HTTP_HX_TRIGGER" => "search")
      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end
  end
end
