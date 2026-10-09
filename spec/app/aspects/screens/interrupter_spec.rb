# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Interrupter do
  subject(:interrupter) { described_class.new positioner: }

  let(:positioner) { instance_spy Terminus::Aspects::Screens::Positioner }

  describe "#call" do
    let(:device) { Factory.structs[:device] }

    it "processes device identify command" do
      device = Factory.structs[:device, command: "identify"]
      identify = instance_spy Terminus::Aspects::Screens::Interrupts::Identify
      interrupter = described_class.new(identify:)

      interrupter.call device, event: "button"

      expect(identify).to have_received(:call).with(device)
    end

    it "processes device screen first command" do
      device = Factory.structs[:device, command: "screen_first"]
      interrupter.call device, event: "button"

      expect(positioner).to have_received(:call).with(device, event: "button", direction: :first)
    end

    it "processes device screen backward command" do
      device = Factory.structs[:device, command: "screen_backward"]
      interrupter.call device, event: "button"

      expect(positioner).to have_received(:call).with(device, event: "button", direction: :backward)
    end

    it "processes device screen forward command" do
      device = Factory.structs[:device, command: "screen_forward"]
      interrupter.call device, event: "button"

      expect(positioner).to have_received(:call).with(device, event: "button", direction: :forward)
    end

    it "processes device screen last command" do
      device = Factory.structs[:device, command: "screen_last"]
      interrupter.call device, event: "button"

      expect(positioner).to have_received(:call).with(device, event: "button", direction: :last)
    end

    it "processes device screen wipe command" do
      device = Factory.structs[:device, command: "screen_wipe"]
      wipe = instance_spy Terminus::Aspects::Screens::Interrupts::Wipe
      interrupter = described_class.new(wipe:)

      interrupter.call device, event: "button"

      expect(wipe).to have_received(:call)
    end

    it "forwards to next screen when event is unknown" do
      device = Factory.structs[:device]
      interrupter.call device

      expect(positioner).to have_received(:call).with(device, direction: :forward)
    end

    it "processes device command for the EXT0 event" do
      device = Factory.structs[:device, command: "screen_first"]
      interrupter.call device, event: "EXT0"

      expect(positioner).to have_received(:call).with(device, event: "EXT0", direction: :first)
    end

    it "renders invalid device command error screen" do
      device = Factory.structs[:device, command: "bogus"]
      error = instance_spy Terminus::Aspects::Screens::Interrupts::Error
      interrupter = described_class.new(error:)

      interrupter.call device, event: "button"

      expect(error).to have_received(:call).with(
        device,
        "Invalid device command: bogus. Please check your device's settings."
      )
    end

    context "when device is asleep" do
      subject(:interrupter) { described_class.new positioner:, sleep: }

      let(:sleep) { instance_spy Terminus::Aspects::Screens::Interrupts::Sleep }

      before { allow(device).to receive(:asleep?).and_return(true) }

      it "remains asleep when button isn't pressed" do
        interrupter.call device, event: "timer"
        expect(sleep).to have_received(:call).with(device)
      end

      it "temporarily wakes when button is pressed" do
        interrupter.call device, event: "button"

        expect(positioner).to have_received(:call).with(
          device,
          event: "button",
          direction: :forward
        )
      end
    end
  end
end
