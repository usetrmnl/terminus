# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Rotator, :db do
  subject(:rotator) { described_class.new }

  describe "#call" do
    let(:device) { provisioner.call(model_id: Factory[:model].id).value! }
    let(:provisioner) { Terminus::Aspects::Devices::Provisioner.new }
    let(:playlist_repository) { Terminus::Repositories::Playlist.new }
    let(:item_repository) { Terminus::Repositories::PlaylistItem.new }

    it "answers sleep screen when device is asleep" do
      allow(device).to receive(:asleep?).and_return true
      expect(rotator.call(device).success).to have_attributes(label: /Sleep/)
    end

    it "answers current screen when playlist has single item" do
      expect(rotator.call(device).success).to have_attributes(label: /Welcome/)
    end

    it "doesn't advance current item when playlist is manual" do
      playlist = playlist_repository.update device.playlist_id, mode: "manual"

      Factory[
        :playlist_item,
        playlist_id: device.playlist_id,
        screen_id: Factory[:screen, label: "Test"].id,
        position: 2
      ]

      rotator.call device

      expect(playlist_repository.find(device.playlist_id)).to have_attributes(
        current_item_id: playlist.current_item_id
      )
    end

    it "answers next screen when current screen isn't last" do
      Factory[
        :playlist_item,
        playlist_id: device.playlist_id,
        screen_id: Factory[:screen, label: "Test"].id,
        position: 2
      ]

      expect(rotator.call(device).success).to have_attributes(label: "Test")
    end

    it "answers first screen when current screen is last screen" do
      screen = Factory[:screen, label: "Test"]

      item = Factory[
        :playlist_item,
        playlist_id: device.playlist_id,
        screen_id: screen.id,
        position: 2
      ]

      playlist_repository.update device.playlist_id, current_item_id: item.id

      expect(rotator.call(device).success).to have_attributes(label: /Welcome/)
    end

    it "answers failure when playlist can't be found" do
      expect(rotator.call(Factory[:device])).to be_failure(
        "Unable to obtain next screen. Can't find playlist with ID: nil."
      )
    end

    it "answers failure when playlist is empty" do
      playlist = Factory[:playlist]
      device = Factory[:device, playlist_id: playlist.id]

      expect(rotator.call(device)).to be_failure(
        "Unable to obtain next screen. Playlist has no items."
      )
    end
  end
end
