# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::Provisioner, :db do
  subject(:provisioner) { described_class.new }

  describe "#call" do
    it "answers existing device with redacted API key" do
      device = Factory[:device, mac_address: "02:A1:B2:C3:D4:E5"]
      result = provisioner.call mac_address: device.mac_address

      expect(result.success).to have_attributes(
        playlist_id: nil,
        api_key: "",
        mac_address: "02:A1:B2:C3:D4:E5"
      )
    end

    context "with firmware reset" do
      let(:device) { Factory[:device, mac_address: "02:A1:B2:C3:D4:E5", firmware_reset: true] }

      it "answers existing device with API key when firmware reset is enabled" do
        result = provisioner.call mac_address: device.mac_address

        expect(result.success).to have_attributes(
          playlist_id: nil,
          api_key: device.api_key,
          mac_address: "02:A1:B2:C3:D4:E5"
        )
      end

      it "answers existing device with redacted API key after firmware reset is disabled" do
        provisioner.call mac_address: device.mac_address
        result = provisioner.call mac_address: device.mac_address

        expect(result.success).to have_attributes(
          playlist_id: nil,
          api_key: "",
          mac_address: "02:A1:B2:C3:D4:E5"
        )
      end
    end

    context "with new device" do
      let(:model) { Factory[:model] }

      it "answers device with given MAC address" do
        result = provisioner.call mac_address: "02:A1:B2:C3:D4:E5", model_id: model.id

        expect(result.success).to have_attributes(
          model_id: model.id,
          mac_address: "02:A1:B2:C3:D4:E5"
        )
      end

      it "answers device with virtual MAC address" do
        result = provisioner.call model_id: model.id

        expect(result.success).to have_attributes(
          model_id: model.id,
          mac_address: match_mac_address
        )
      end

      it "associates existing playlist" do
        playlist = Factory[:playlist]
        device = provisioner.call(model_id: model.id, playlist_id: playlist.id).success

        expect(device).to have_attributes(playlist_id: playlist.id)
      end

      it "associates device with new playlist" do
        device = provisioner.call(mac_address: "02:A1:B2:C3:D4:E5", model_id: model.id).success
        playlist = Terminus::Repositories::Playlist.new.find device.playlist_id

        expect(playlist).to have_attributes(
          label: "Device #{device.id}",
          name: "device_#{device.id}"
        )
      end

      it "associates playlist item with welcome screen" do
        device = provisioner.call(mac_address: "02:A1:B2:C3:D4:E5", model_id: model.id).success
        item = Terminus::Repositories::PlaylistItem.new.find_by playlist_id: device.playlist_id
        screen = item.screen

        expect(screen).to have_attributes(
          model_id: model.id,
          label: "Welcome #{device.id}",
          name: "welcome_#{device.id}"
        )
      end

      it "associates playlist current item with welcome screen" do
        device = provisioner.call(mac_address: "02:A1:B2:C3:D4:E5", model_id: model.id).success
        playlist = Terminus::Repositories::Playlist.new.find device.playlist_id
        screen = Terminus::Repositories::Screen.new.find playlist.current_item.screen_id

        expect(screen).to have_attributes(
          label: "Welcome #{device.id}",
          name: "welcome_#{device.id}"
        )
      end

      it "answers failure with nil model ID" do
        result = provisioner.call mac_address: "02:A1:B2:C3:D4:E5", model_id: nil

        expect(result).to be_failure(
          %(Null value in column "model_id" of relation "device" violates not-null constraint.)
        )
      end

      it "answers failure with invalid model ID" do
        result = provisioner.call mac_address: "02:A1:B2:C3:D4:E5", model_id: 13
        expect(result).to be_failure(%(Key (model_id)=(13) is not present in table "model".))
      end
    end
  end
end
