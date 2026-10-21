# frozen_string_literal: true

require "core"
require "dry/monads"
require "pipeable"

module Terminus
  module Aspects
    module Devices
      # Handles the setup and default configuration of new devices.
      class Provisioner
        include Deps[
          "aspects.devices.defaulter",
          "aspects.screens.interrupts.welcome",
          repository: "repositories.device",
          playlist_repository: "repositories.playlist",
          item_repository: "repositories.playlist_item"
        ]

        include Dry::Monads[:result]
        include Pipeable

        def call(mac_address: MACAddressBuilder.call, **)
          device = repository.find_by(mac_address:)

          return maybe_redact_api_key device if device

          process(mac_address, **)
        end

        private

        def maybe_redact_api_key device
          if device.firmware_reset
            repository.update device.id, firmware_reset: false
          else
            device.define_singleton_method(:api_key) { Core::EMPTY_STRING }
          end

          Success device
        end

        def process(mac_address, **)
          cached_device = nil

          pipe(
            create(mac_address, **),
            fmap { cached_device = it },
            bind { welcome.call cached_device },
            fmap { |screen| configure cached_device, screen }
          )
        end

        def create(mac_address, **)
          Success repository.create(defaulter.call.merge!(mac_address:, **))
        rescue ROM::SQL::NotNullConstraintError => error
          Failure "#{error.message.match(/ERROR:  (.+)\n/)[1].capitalize}."
        rescue ROM::SQL::ForeignKeyConstraintError => error
          Failure error.message.sub(/.+DETAIL:  /m, "").strip
        end

        def configure device, screen
          playlist_id = create_playlist_id device
          item = item_repository.create_with_position playlist_id:, screen_id: screen.id

          playlist_repository.update playlist_id, current_item_id: item.id
          repository.find repository.update(device.id, playlist_id:).id
        end

        def create_playlist_id device
          id = device.id
          playlist = playlist_repository.create label: "Device #{id}", name: "device_#{id}"

          playlist.id
        end
      end
    end
  end
end
