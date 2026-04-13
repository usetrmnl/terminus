# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Fetcher, :db do
  subject(:fetcher) { described_class.new }

  describe "#call" do
    let(:device) { provisioner.call(model_id: Factory[:model].id).value! }
    let(:provisioner) { Terminus::Aspects::Devices::Provisioner.new }
    let(:playlist_repository) { Terminus::Repositories::Playlist.new }
    let(:item_repository) { Terminus::Repositories::PlaylistItem.new }

    it "answers welcome screen when device is new" do
      expect(fetcher.call(device).success).to have_attributes(label: /Welcome/)
    end

    it "answers custom screen when device has updated playlist" do
      playlist = playlist_repository.find device.playlist_id
      result = Terminus::Aspects::Screens::Upserter.new.call model_id: device.model_id,
                                                             label: "Test",
                                                             name: "test",
                                                             content: "<h1>Test</h1>"

      result.bind do |screen|
        item = item_repository.create_with_position playlist_id: playlist.id, screen_id: screen.id
        playlist_repository.update playlist.id, current_item_id: item.id
      end

      expect(fetcher.call(device).success).to have_attributes(label: /Test/)
    end

    it "answers sleep screen when device is asleep" do
      allow(device).to receive(:asleep?).and_return true
      expect(fetcher.call(device).success).to have_attributes(label: /Sleep/)
    end

    it "answers failure when device has no playlist" do
      device = Factory[:device]

      expect(fetcher.call(device)).to be_failure(
        "Unable to fetch screen. Can't find playlist with ID: nil."
      )
    end

    it "answers failure when device has no playlist current item" do
      playlist = Factory[:playlist]
      device = Factory[:device, playlist_id: playlist.id]

      expect(fetcher.call(device)).to be_failure(
        "Unable to fetch screen. Can't find current playlist item with ID: nil."
      )
    end
  end
end
