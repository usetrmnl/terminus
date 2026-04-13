# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Device, :db do
  using Refinements::Pathname

  subject(:part) { described_class.new value: device, rendering: view.new.rendering }

  let(:device) { Factory[:device] }

  let :view do
    Class.new Hanami::View do
      config.paths = [Hanami.app.root.join("app/templates")]
      config.template = "n/a"
    end
  end

  describe "#current_screen" do
    let :device do
      Terminus::Aspects::Devices::Provisioner.new.call(model_id: Factory[:model].id).value!
    end

    it "answers screen when device is provisioned" do
      expect(part.current_screen).to be_a(Terminus::Structs::Screen)
    end

    context "without playlist" do
      let(:device) { Factory[:device] }

      it "answers placeholder when device has no playlist" do
        expect(part.current_screen).to eq(Terminus::Aspects::Screens::Placeholder[id: device.id])
      end
    end
  end

  describe "#dimensions" do
    it "answers default width and height" do
      expect(part.dimensions).to eq("0x0")
    end

    context "with custom dimensions" do
      let(:device) { Factory[:device, width: 800, height: 480] }

      it "answers custom width and height" do
        expect(part.dimensions).to eq("800x480")
      end
    end
  end

  describe "#battery_percentage" do
    it "answers percentage when charge is positive" do
      allow(device).to receive(:battery_charge).and_return(85)
      expect(part.battery_percentage).to eq(85)
    end

    it "answers zero when voltage is zero" do
      allow(device).to receive(:battery_voltage).and_return(0)
      expect(part.battery_percentage).to eq(0)
    end

    it "answers ten percent when voltage is extremely low" do
      allow(device).to receive(:battery_voltage).and_return(0.1)
      expect(part.battery_percentage).to eq(10)
    end

    it "answers ten percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(0.25)
      expect(part.battery_percentage).to eq(10)
    end

    it "answers twenty percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(0.75)
      expect(part.battery_percentage).to eq(20)
    end

    it "answers thirty percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(1.15)
      expect(part.battery_percentage).to eq(30)
    end

    it "answers fourty percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(1.5)
      expect(part.battery_percentage).to eq(40)
    end

    it "answers fifty percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(2.0)
      expect(part.battery_percentage).to eq(50)
    end

    it "answers sixty percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(2.5)
      expect(part.battery_percentage).to eq(60)
    end

    it "answers seventy percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(3.0)
      expect(part.battery_percentage).to eq(70)
    end

    it "answers eighty percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(3.3)
      expect(part.battery_percentage).to eq(80)
    end

    it "answers ninety percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(3.9)
      expect(part.battery_percentage).to eq(90)
    end

    it "answers one hundred percent when voltage is in range" do
      allow(device).to receive(:battery_voltage).and_return(4.8)
      expect(part.battery_percentage).to eq(100)
    end

    it "answers one hundred percent when voltage is beyond range" do
      allow(device).to receive(:battery_voltage).and_return(4.5)
      expect(part.battery_percentage).to eq(100)
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

  describe "#wifi_percentage" do
    it "answers zero when zero" do
      allow(device).to receive(:wifi).and_return(0)
      expect(part.wifi_percentage).to eq(0)
    end

    it "answers ten percent when extremely low" do
      allow(device).to receive(:wifi).and_return(-100)
      expect(part.wifi_percentage).to eq(10)
    end

    it "answers ten percent when in range" do
      allow(device).to receive(:wifi).and_return(-95)
      expect(part.wifi_percentage).to eq(10)
    end

    it "answers twenty percent when in range" do
      allow(device).to receive(:wifi).and_return(-85)
      expect(part.wifi_percentage).to eq(20)
    end

    it "answers thirty percent when in range" do
      allow(device).to receive(:wifi).and_return(-75)
      expect(part.wifi_percentage).to eq(30)
    end

    it "answers fourty percent when in range" do
      allow(device).to receive(:wifi).and_return(-69)
      expect(part.wifi_percentage).to eq(40)
    end

    it "answers fifty percent when in range" do
      allow(device).to receive(:wifi).and_return(-65)
      expect(part.wifi_percentage).to eq(50)
    end

    it "answers sixty percent when in range" do
      allow(device).to receive(:wifi).and_return(-59)
      expect(part.wifi_percentage).to eq(60)
    end

    it "answers seventy percent when in range" do
      allow(device).to receive(:wifi).and_return(-54)
      expect(part.wifi_percentage).to eq(70)
    end

    it "answers eighty percent when in range" do
      allow(device).to receive(:wifi).and_return(-49)
      expect(part.wifi_percentage).to eq(80)
    end

    it "answers ninety percent when in range" do
      allow(device).to receive(:wifi).and_return(-45)
      expect(part.wifi_percentage).to eq(90)
    end

    it "answers one hundred percent when in range" do
      allow(device).to receive(:wifi).and_return(-25)
      expect(part.wifi_percentage).to eq(100)
    end
  end
end
