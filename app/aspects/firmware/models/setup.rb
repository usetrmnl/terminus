# frozen_string_literal: true

require "securerandom"

module Terminus
  module Aspects
    module Firmware
      module Models
        # Models data for API setup responses.
        Setup = Struct.new :api_key, :image_url, :message, :status do
          def self.welcome settings: Hanami.app[:settings], randomizer: SecureRandom
            new api_key: randomizer.alphanumeric(30),
                image_url: %(#{settings.api_uri}/assets/setup.bmp),
                message: "Welcome to Terminus!",
                status: 200
          end

          def initialize(**)
            super
            self[:message] ||= "Device not registered."
            self[:status] ||= 404
            freeze
          end

          def to_json(*) = to_h.to_json(*)
        end
      end
    end
  end
end
