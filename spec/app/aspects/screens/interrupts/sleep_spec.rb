# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Interrupts::Sleep, :db do
  subject(:interrupter) { described_class.new }

  describe "#call" do
    let(:device) { Factory[:device, model_id: model.id] }
    let(:model) { Factory[:model] }

    it "answers existing screen when found" do
      screen = Factory[
        :screen,
        model_id: model.id,
        device_id: device.id,
        label: "#{device.label} (Sleep)",
        name: "sleep_#{device.id}",
        kind: "sleep"
      ]

      expect(interrupter.call(device).success).to have_attributes(
        id: screen.id,
        label: "#{device.label} (Sleep)",
        name: "sleep_#{device.id}"
      )
    end

    it "answers new screen when not found" do
      expect(interrupter.call(device).success).to have_attributes(
        label: "#{device.label} (Sleep)",
        name: "sleep_#{device.id}",
        image_attributes: hash_including(
          metadata: hash_including(
            filename: "sleep_#{device.id}.png",
            mime_type: "image/png",
            width: 800,
            height: 480
          )
        )
      )
    end
  end
end
