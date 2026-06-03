# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::Device, :db do
  subject :device do
    Factory.structs[:device, image_timeout: 10, mac_address: "AA:BB:CC:11:22:33", refresh_rate: 20]
  end

  describe "#asleep?" do
    subject :device do
      Factory[
        :device,
        sleep_start_at: Time.utc(2025, 1, 1, 1, 1, 0),
        sleep_stop_at: Time.utc(2025, 1, 1, 1, 10, 0)
      ]
    end

    it "answers true when current time is within same day" do
      expect(device.asleep?(Time.utc(2025, 1, 1, 1, 5, 0))).to be(true)
    end

    it "answers false when current time is outside same day" do
      expect(device.asleep?(Time.utc(2025, 1, 1, 1, 20, 0))).to be(false)
    end

    context "when crossing midnight" do
      subject :device do
        Factory[
          :device,
          sleep_start_at: Time.utc(2025, 1, 1, 22, 0, 0),
          sleep_stop_at: Time.utc(2025, 1, 1, 5, 0, 0)
        ]
      end

      it "answers true when current time is within range" do
        expect(device.asleep?(Time.utc(2025, 1, 1, 1, 0, 0))).to be(true)
      end

      it "answers false when current time is outside range" do
        expect(device.asleep?(Time.utc(2025, 1, 1, 6, 0, 0))).to be(false)
      end
    end

    it "answers false when start and end are nil" do
      expect(Factory.structs[:device].asleep?).to be(false)
    end
  end

  describe "#display_attributes" do
    it "answers display specific attributes" do
      expect(device.display_attributes).to eq(
        image_url_timeout: 10,
        maximum_compatibility: false,
        refresh_rate: 20,
        temperature_profile: "default",
        touchbar_mode: "tap",
        update_firmware: true
      )
    end
  end

  describe "#slug" do
    it "answers string with no colons" do
      expect(device.slug).to eq("AABBCC112233")
    end

    it "answers empty string when slug is nil" do
      device = Factory.structs[:device, mac_address: nil]
      expect(device.slug).to eq("")
    end
  end

  describe "#screen_label" do
    it "answers label with prefix" do
      expect(device.screen_label("Test")).to eq("Test ABC123")
    end
  end

  describe "#screen_name" do
    it "answers name with kind" do
      expect(device.screen_name("test")).to eq("terminus_test_abc123")
    end
  end

  describe "#screen_attributes" do
    it "answers attributes" do
      expect(device.screen_attributes("test")).to eq(
        model_id: device.model_id,
        label: "Test ABC123",
        name: "terminus_test_abc123"
      )
    end
  end
end
