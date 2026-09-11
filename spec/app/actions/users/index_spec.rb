# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Users::Index, :db do
  subject(:action) { described_class.new }

  include_context "with user statuses"

  describe "#call" do
    let(:user) { Factory[:user, :verified] }

    it "renders default response with search results" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: user.name})
      expect(response.body.first).to include(%(<h2 class="label">#{user.name}</h2>))
    end

    it "renders default response with no results" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "bogus"})
      expect(response.body.first).to include("No users found.")
    end

    it "renders htmx response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: user.name}
      )

      expect(response.body.first).to include(%(<h2 class="label">#{user.name}</h2>))
    end

    it "renders htmx response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No users found.")
    end

    it "renders all users with no query" do
      user
      response = action.call Rack::MockRequest.env_for("", "HTTP_HX_SOURCE" => "input#search")

      expect(response.body.first).to include(%(<h2 class="label">#{user.name}</h2>))
    end
  end
end
