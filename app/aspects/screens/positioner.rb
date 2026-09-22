# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Screens
      # Updates a device's current playlist item by position.
      class Positioner
        include Deps[
          :i18n,
          :logger,
          playlist_repository: "repositories.playlist",
          item_repository: "repositories.playlist_item"
        ]
        include Initable[
          directions: {forward: :subsequent, backward: :previous, first: :first, last: :last}
        ]
        include Dry::Monads[:result]

        def call device, direction: :forward
          find_playlist(device).bind { |playlist| update playlist, by: direction }
                               .bind { |item| obtain_screen item }
        end

        private

        def find_playlist device
          id = device.playlist_id
          playlist = playlist_repository.find id

          return Success playlist if playlist

          Failure "Unable to obtain next screen. Can't find playlist with ID: #{id.inspect}."
        end

        # :reek:TooManyStatements
        def update playlist, by:
          direction = directions[by]

          return Failure "Invalid playlist direction to move to: #{by}." unless direction

          item = find_item playlist, direction

          playlist_repository.update_current_item playlist, item
          logger.debug { "Updated playlist #{playlist.id} current item position by moving: #{by}." }
          Success item
        end

        def find_item playlist, direction
          playlist_id = playlist.id

          case direction
            when :previous, :subsequent
              item_repository.public_send direction,
                                          playlist_id:,
                                          position: playlist.current_item_position
            else item_repository.public_send direction, playlist_id:
          end
        end

        def obtain_screen item
          return Success item.screen if item

          Failure i18n.translate("aspects.screens.positioner.empty_playlist")
        end
      end
    end
  end
end
