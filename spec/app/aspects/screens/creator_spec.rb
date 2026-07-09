# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Creator, :db do
  subject(:creator) { described_class.new }

  describe "#call" do
    let(:model) { Factory[:model] }
    let(:device) { Factory[:device, model_id: model.id] }

    it "answers existing screen when found" do
      screen = Factory[
        :screen,
        model_id: model.id,
        label: "Welcome",
        name: "welcome",
        kind: "welcome"
      ]

      result = creator.call model_id: model.id, name: "test", kind: "welcome"

      expect(result.success).to have_attributes(
        id: screen.id,
        label: "Welcome",
        name: "welcome",
        kind: "welcome"
      )
    end

    it "answers new screen when not found" do
      result = creator.call model_id: model.id,
                            device_id: device.id,
                            label: "Welcome",
                            name: "welcome",
                            kind: "welcome",
                            content: "<h1>Test</h1>"

      expect(result.success).to have_attributes(
        model_id: model.id,
        device_id: device.id,
        label: "Welcome",
        name: "welcome",
        kind: "welcome",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 800,
            height: 480,
            filename: "welcome.png",
            mime_type: "image/png"
          )
        )
      )
    end
  end
end
