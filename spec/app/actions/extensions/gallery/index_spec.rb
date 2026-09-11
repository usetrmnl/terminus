# frozen_string_literal: true

require "hanami_helper"
require "trmnl/api"

RSpec.describe Terminus::Actions::Extensions::Gallery::Index do
  subject(:action) { described_class.new trmnl_api: }

  let :trmnl_api do
    instance_double TRMNL::API::Client,
                    recipes: Success(TRMNL::API::Models::Recipe.for(**attributes))
  end

  let :attributes do
    {
      data: [
        {
          id: 1,
          name: "Test I",
          published_at: "2026-01-13T13:00:32.349Z",
          icon_url: "https://icons.sereinity.space/test_i.png",
          icon_content_type: "image/png",
          screenshot_url: "https://screens.trmnl.io/test_i.png",
          author_bio: {
            keyname: "bio",
            name: " Malcolm Reynolds",
            field_type: "author_bio",
            description: "Ship captain.",
            github_url: "https://github.com/mreynolds",
            learn_more_url: "https://sereinity.space/mreynolds"
          },
          custom_fields: [],
          stats: {
            installs: 6,
            forks: 0
          }
        }
      ],
      total: 100,
      from: 1,
      to: 25,
      per_page: 25,
      current_page: 1,
      prev_page_url: nil,
      next_page_url: "/recipes.json?page=2"
    }
  end

  describe "#call" do
    it "renders response with matching page and search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {page: 1, query: "Test I"}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test I</h2>))
    end

    it "renders response with matching page" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {page: 1})
      expect(response.body.first).to include(%(<h2 class="label">Test I</h2>))
    end

    it "renders response with matching search results" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "Test I"})

      expect(response.body.first).to include(%(<h2 class="label">Test I</h2>))
    end

    it "renders response with no matching search results" do
      attributes[:data] = []
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "bogus"})

      expect(response.body.first).to include("No recipes found.")
    end

    it "renders htmx response with matching search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_REQUEST" => "true",
        "router.params" => {query: "Test I"}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test I</h2>))
    end

    it "renders htmx response with no mactching search results" do
      attributes[:data] = []

      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No recipes found.")
    end

    it "renders all extensions with no query" do
      response = action.call Rack::MockRequest.env_for("", "HTTP_HX_REQUEST" => "true")

      expect(response.body.first).to include(%(<h2 class="label">Test I</h2>))
    end

    context "with single message failure" do
      let(:trmnl_api) { instance_double TRMNL::API::Client, recipes: Failure("Danger!") }

      it "flashes alert" do
        response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "Test I"})
        expect(response.body.first).to match(/site-alert.+Danger!/m)
      end
    end

    context "with validation failures" do
      let :trmnl_api do
        attributes.dig(:data, 0).delete :name

        instance_double TRMNL::API::Client,
                        recipes: Failure(TRMNL::API::Schemas::Recipe.call(attributes))
      end

      it "flashes alert" do
        response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "Test I"})
        expect(response.body.first).to match(/site-alert.+Gallery data\.0\.name is missing\./m)
      end
    end

    context "with unknown failure" do
      let(:trmnl_api) { instance_double TRMNL::API::Client, recipes: 666 }

      it "flashes alert" do
        response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "Test I"})
        expect(response.body.first).to match(/site-alert.+Unable to process TRMNL API\./m)
      end
    end
  end
end
