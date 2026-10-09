# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Positioner, :db do
  subject(:positioner) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:device) { provisioner.call(model_id: Factory[:model].id).value! }
    let(:provisioner) { Terminus::Aspects::Devices::Provisioner.new }
    let(:playlist_repository) { Terminus::Repositories::Playlist.new }
    let(:item_repository) { Terminus::Repositories::PlaylistItem.new }

    it "answers current screen when playlist has single item" do
      expect(positioner.call(device).success).to have_attributes(label: /Welcome/)
    end

    it "answers next screen when current screen isn't last" do
      Factory[
        :playlist_item,
        playlist_id: device.playlist_id,
        screen_id: Factory[:screen, label: "Test"].id,
        position: 2
      ]

      expect(positioner.call(device).success).to have_attributes(label: "Test")
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

      expect(positioner.call(device).success).to have_attributes(label: /Welcome/)
    end

    it "answers last screen when current screen is last screen" do
      screen = Factory[:screen, label: "Test"]

      item = Factory[
        :playlist_item,
        playlist_id: device.playlist_id,
        screen_id: screen.id,
        position: 2
      ]

      playlist_repository.update device.playlist_id, current_item_id: item.id

      expect(positioner.call(device, direction: :last).success).to have_attributes(label: /Test/)
    end

    context "with manual playlist" do
      before { playlist_repository.update device.playlist_id, mode: "manual" }

      it "answers current screen and does not advance position" do
        screen = positioner.call(device).value!
        expect(positioner.call(device).value!).to have_attributes(id: screen.id)
      end

      it "answers next screen when event is given" do
        positioner.call device

        screen = Factory[:screen, label: "Test"]

        Factory[
          :playlist_item,
          playlist_id: device.playlist_id,
          screen_id: screen.id,
          position: 2
        ]

        expect(positioner.call(device, event: "button").success).to have_attributes(id: screen.id)
      end
    end

    it "logs debug message for movement" do
      positioner.call device
      expect(logger.reread).to match(/DEBUG.+Updated playlist.+\d+.+moving.+forward/)
    end

    it "answers failure with invalid direction" do
      expect(positioner.call(device, direction: :bogus)).to be_failure(
        "Invalid playlist direction to move to: bogus."
      )
    end

    it "answers failure when playlist can't be found" do
      expect(positioner.call(Factory[:device])).to be_failure(
        "Unable to obtain next screen. Can't find playlist with ID: nil."
      )
    end

    it "answers failure when playlist is empty" do
      playlist = Factory[:playlist]
      device = Factory[:device, playlist_id: playlist.id]

      expect(positioner.call(device)).to be_failure(
        "Unable to obtain next screen. Playlist has no items."
      )
    end
  end
end
