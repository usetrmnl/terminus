# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Playlist, :db do
  subject :part do
    playlist = Factory[:playlist]
    screen = Factory[:screen, :with_image]
    item = Factory[:playlist_item, playlist_id: playlist.id, screen_id: screen.id]

    repository = Terminus::Repositories::Playlist.new
    repository.update playlist.id, current_item_id: item.id

    described_class.new value: repository.find(playlist.id), rendering:
  end

  let(:rendering) { Terminus::View.new.rendering }

  before { allow(rendering).to receive(:context).and_return Terminus::Views::Context.new }

  describe "#mode_label" do
    it "answers capitalized label" do
      expect(part.mode_label).to eq("Automatic")
    end
  end

  describe "#current_screen_pill" do
    it "answers pill when current item, screen, and image exist" do
      expect(part.current_screen_pill(part.current_item)).to eq(
        %(<div class="bit-pill bit-pill-active">Current Screen</div>)
      )
    end

    it "answers pill with custom label" do
      expect(part.current_screen_pill(part.current_item, "Test")).to eq(
        %(<div class="bit-pill bit-pill-active">Test</div>)
      )
    end

    it "answers nil when current item is missing" do
      part = described_class.new(value: Factory[:playlist], rendering:)
      item = Factory[:playlist_item]

      expect(part.current_screen_pill(item)).to be(nil)
    end
  end

  describe "#current_screen" do
    it "answers screen when current item, screen, and image exist" do
      expect(part.current_screen).to be_a(Terminus::Structs::Screen)
    end

    it "answers placeholder when current item is missing" do
      playlist = Factory[:playlist]
      part = described_class.new(value: playlist, rendering:)

      expect(part.current_screen).to eq(
        Terminus::Aspects::Screens::Faux[id: playlist.id, uri: "blank.svg"]
      )
    end
  end
end
