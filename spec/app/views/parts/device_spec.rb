# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Device, :db do
  subject(:part) { described_class.new value: device, rendering: Terminus::View.new.rendering }

  let(:device) { Factory.structs[:device] }

  describe "#current_screen" do
    let :device do
      Terminus::Aspects::Devices::Provisioner.new.call(model_id: Factory[:model].id).value!
    end

    it "answers screen when device is provisioned" do
      expect(part.current_screen).to be_a(Terminus::Structs::Screen)
    end

    context "without playlist" do
      let(:device) { Factory.structs[:device] }

      it "answers placeholder when device has no playlist" do
        expect(part.current_screen).to eq(Terminus::Aspects::Screens::Placeholder[id: device.id])
      end
    end
  end

  describe "#dimensions" do
    let(:device) { Factory.structs[:device, width: 0, height: 0] }

    it "answers zero width and height" do
      expect(part.dimensions).to eq("0x0")
    end

    context "with custom dimensions" do
      let(:device) { Factory.structs[:device, width: 800, height: 480] }

      it "answers custom width and height" do
        expect(part.dimensions).to eq("800x480")
      end
    end
  end

  describe "#battery_measurement_label" do
    it "answers only percentage when not charging" do
      expect(part.battery_measurement_label).to eq("Battery (70%)")
    end

    it "answers charging when charging" do
      allow(device).to receive(:charging).and_return(true)
      expect(part.battery_measurement_label).to eq("Charging")
    end

    it "answers charging when battery voltage is at minimum voltage" do
      allow(device).to receive(:battery_voltage).and_return(4.2)
      expect(part.battery_measurement_label).to eq("Charging")
    end

    it "answers charging when battery voltage is higher than minimum voltage" do
      allow(device).to receive(:battery_voltage).and_return(4.5)
      expect(part.battery_measurement_label).to eq("Charging")
    end
  end

  describe "#formatted_display_profile" do
    it "answers capitalized label" do
      expect(part.formatted_display_profile).to eq("Default")
    end
  end

  describe "#formatted_touch_bar" do
    it "answers capitalized label" do
      expect(part.formatted_touch_bar).to eq("Tap")
    end
  end

  describe "#translated_command" do
    it "answers translation" do
      expect(part.translated_command).to eq("Next Screen")
    end
  end

  describe "#wake_description" do
    it "answers unknown when blank" do
      expect(part.wake_description).to eq("Unknown.")
    end

    it "answers description when present" do
      allow(device).to receive(:wake_reason).and_return("Woken from test.")
      expect(part.wake_description).to eq("Woken from test.")
    end
  end

  describe "#wifi_measurement_label" do
    it "answers only signal strength when band is zero" do
      expect(part.wifi_measurement_label).to eq("WiFi (90%)")
    end

    it "answers band and signal when band is positive" do
      allow(device).to receive(:wifi_band).and_return(2.4)
      expect(part.wifi_measurement_label).to eq("2.4 GHz (90%)")
    end
  end
end
