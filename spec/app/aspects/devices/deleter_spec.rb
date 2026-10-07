# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::Deleter, :db do
  subject(:deleter) { described_class.new }

  describe "#call" do
    let(:device) { Factory[:device] }
    let(:repository) { Terminus::Repositories::Device.new }

    it "deletes associated error screen" do
      Factory[:screen, device_id: device.id, kind: "error"]
      deleter.call device.id

      expect(Terminus::Repositories::Screen.new.all).to eq([])
    end

    it "deletes associated welcome screen" do
      Factory[:screen, device_id: device.id, kind: "welcome"]
      deleter.call device.id

      expect(Terminus::Repositories::Screen.new.all).to eq([])
    end

    it "doesn't delete allowed screen kind" do
      screen = Factory[:screen, device_id: device.id, kind: "general"]
      deleter.call device.id

      expect(Terminus::Repositories::Screen.new.all.map(&:id)).to contain_exactly(screen.id)
    end

    it "deletes device" do
      deleter.call device.id
      expect(repository.find(device.id)).to be(nil)
    end

    it "answers deleted device" do
      expect(deleter.call(device.id)).to have_attributes(id: device.id)
    end
  end
end
