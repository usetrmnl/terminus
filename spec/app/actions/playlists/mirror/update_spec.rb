# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Playlists::Mirror::Update, :db do
  subject(:action) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:playlist) { Factory[:playlist] }
    let(:device) { Factory[:device] }

    it "answers not found for unknown playlist" do
      response = action.call id: 666
      expect(response.status).to eq(404)
    end

    it "renders non-htmx response" do
      response = action.call id: playlist.id
      expect(response.body.first).to include("<!DOCTYPE html>")
    end

    context "with htmx request" do
      let :response do
        action.call Rack::MockRequest.env_for(
          playlist.id.to_s,
          "HTTP_HX_REQUEST" => "true",
          "router.params" => {id: playlist.id}
        )
      end

      it "includes push URL header" do
        expect(response.headers).to include(
          "HX-Push-Url" => routes.path(:playlist, id: playlist.id)
        )
      end

      it "renders htmx response" do
        expect(response.body.first).to have_htmx_title(/Playlist \d+ Playlist/)
      end
    end
  end
end
