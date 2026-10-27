# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Devices::Imports::Device do
  subject(:contract) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        model_name: "test",
        playlist_id: nil,
        label: "Test",
        mac_address: "AA:BB:CC:11:22:33",
        api_key: "secret",
        refresh_rate: 100,
        image_timeout: 0,
        firmware_update: "on",
        sleep_start_at: "01:00:00",
        sleep_stop_at: "02:00:00"
      }
    end

    it "answers success when valid" do
      expect(contract.call(attributes)).to be_success
    end

    it "answers success when start and end date/time are nil" do
      attributes.delete :sleep_start_at
      attributes.delete :sleep_stop_at

      expect(contract.call(attributes)).to be_success
    end

    it "answers failures when start is missing but stop is present" do
      attributes[:sleep_start_at] = nil

      expect(contract.call(attributes).errors.to_h).to eq(
        sleep_start_at: ["must be filled"],
        sleep_stop_at: ["must have corresponding start time"]
      )
    end

    it "answers failures when start is present but stop is missing" do
      attributes[:sleep_stop_at] = nil

      expect(contract.call(attributes).errors.to_h).to eq(
        sleep_start_at: ["must have corresponding stop time"],
        sleep_stop_at: ["must be filled"]
      )
    end
  end
end
