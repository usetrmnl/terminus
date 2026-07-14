# frozen_string_literal: true

require "securerandom"

module Terminus
  module Aspects
    module Devices
      # Builds default attributes for new devices.
      class Defaulter
        def initialize randomizer: SecureRandom, mac_address_builder: Devices::MACAddressBuilder
          @randomizer = randomizer
          @mac_address_builder = mac_address_builder
        end

        def call
          {
            api_key: randomizer.alphanumeric(30),
            firmware_update: true,
            image_timeout: 0,
            label: "TRMNL",
            mac_address: mac_address_builder.call,
            refresh_rate: 900
          }
        end

        private

        attr_reader :randomizer, :mac_address_builder
      end
    end
  end
end
