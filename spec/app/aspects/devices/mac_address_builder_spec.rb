# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::MACAddressBuilder do
  subject(:builder) { described_class }

  describe "#call" do
    let(:randomizer) { class_double SecureRandom }

    it "answers random address" do
      result = Terminus::Types::MACAddress.valid? builder.call
      expect(result).to be(true)
    end

    it "ensures first octet ends in 2 for valid locally administered (unicast) address" do
      allow(randomizer).to receive(:bytes).with(6) do
        [0b00000000, 0x3d, 0x7c, 0x70, 0xa9, 0x0a].pack "C*"
      end

      expect(builder.call(randomizer:)).to eq("02:3D:7C:70:A9:0A")
    end

    it "ensures first octet ends in 6 for valid locally administered (unicast) address" do
      allow(randomizer).to receive(:bytes).with(6) do
        [0b00000100, 0x3d, 0x7c, 0x70, 0xa9, 0x0a].pack "C*"
      end

      expect(builder.call(randomizer:)).to eq("06:3D:7C:70:A9:0A")
    end

    it "ensures first octet ends in A for valid locally administered (unicast) address" do
      allow(randomizer).to receive(:bytes).with(6) do
        [0b00001000, 0x3d, 0x7c, 0x70, 0xa9, 0x0a].pack "C*"
      end

      expect(builder.call(randomizer:)).to eq("0A:3D:7C:70:A9:0A")
    end

    it "ensures first octet ends in E for valid locally administered (unicast) address" do
      allow(randomizer).to receive(:bytes).with(6) do
        [0b00001100, 0x3d, 0x7c, 0x70, 0xa9, 0x0a].pack "C*"
      end

      expect(builder.call(randomizer:)).to eq("0E:3D:7C:70:A9:0A")
    end
  end
end
