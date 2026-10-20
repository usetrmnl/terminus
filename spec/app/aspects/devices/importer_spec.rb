# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::Importer do
  subject(:importer) { described_class.new }

  describe "#call" do
    let(:repository) { Terminus::Repositories::Device.new }

    let :content do
      <<~CSV
        Label,Model Name,Playlist Name,MAC Address,API Key,Refresh Rate,Image Timeout,Firmware Update,Display Compatibility,Display Profile,Command,Touch Bar,Sleep Start,Sleep Stop
        Test A,test,test,1E:B2:16:6D:7B:AB,abc123y,100,10,true,true,A,screen_forward,swipe,20:00:00,06:00:00
        Test B,test,test,DA:D5:B9:A0:D1:5F,abc123z,100,10,true,true,A,screen_forward,swipe,20:00:00,06:00:00
      CSV
    end

    it "imports devices" do
      importer.call content
      expect(repository.all.map(&:mac_address)).to eq(%w[1E:B2:16:6D:7B:AB DA:D5:B9:A0:D1:5F])
    end
  end
end
