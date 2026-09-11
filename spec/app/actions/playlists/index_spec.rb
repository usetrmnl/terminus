# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Playlists::Index, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let :playlist do
      playlist = Factory[:playlist, label: "Test", name: "test"]
      screen = Factory[:screen, :with_image]
      item = Factory[:playlist_item, playlist_id: playlist.id, screen_id: screen.id]

      repository = Terminus::Repositories::Playlist.new
      repository.update playlist.id, current_item_id: item.id
      repository.find playlist.id
    end

    it "renders default response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {query: playlist.label}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end

    it "renders default response with no results" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {query: "bogus"})
      expect(response.body.first).to include("No playlists found.")
    end

    it "renders htmx response with search results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: playlist.label}
      )

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end

    it "renders htmx response with no results" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "HTTP_HX_SOURCE" => "input#search",
        "router.params" => {query: "bogus"}
      )

      expect(response.body.first).to include("No playlists found.")
    end

    it "renders all playlists with no query" do
      playlist
      response = action.call Rack::MockRequest.env_for("", "HTTP_HX_SOURCE" => "input#search")

      expect(response.body.first).to include(%(<h2 class="label">Test</h2>))
    end
  end
end
