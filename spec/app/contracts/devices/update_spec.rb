# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Devices::Update do
  subject(:contract) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        id: 1,
        device: {
          model_id: 1,
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
      }
    end

    it_behaves_like "a sleep contract"
  end
end
