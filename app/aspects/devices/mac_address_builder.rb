# frozen_string_literal: true

require "securerandom"

module Terminus
  module Aspects
    module Devices
      # Builds a random, locally administered, unicast MAC address.
      MACAddressBuilder = lambda do |randomizer: SecureRandom|
        zero_mask = 0xFC   # 11111100
        local_mask = 0x02  # 00000010
        bytes = randomizer.bytes(6).unpack "C*"
        bytes[0] = (bytes[0] & zero_mask) | local_mask

        bytes.map { format "%02X", it }
             .join ":"
      end
    end
  end
end
