# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "metapath"
require "refinements/hash"
require "refinements/pathname"

module Terminus
  module Aspects
    module Screens
      # Imports metadata enriched images as screens for rendering on devices.
      class Importer
        include Deps[
          "aspects.screens.upserter",
          :logger,
          model_repository: "repositories.model",
          item_repository: "repositories.playlist_item",
          playlist_repository: "repositories.playlist"
        ]
        include Initable[metapath: proc { Metapath.new }]
        include Dry::Monads[:result]

        using Refinements::Hash
        using Refinements::Pathname

        def call root
          case metapath.call root
            in Success(*records) then setup records
            in Failure(message) then logger.error { message }
          end
        end

        private

        def setup records
          playlist = find_or_create_playlist records
          item_repository.delete_all playlist_id: playlist.id
          process(playlist, records).tap { update_current_item playlist }
        end

        def find_or_create_playlist records
          records.first
                 .fetch("playlist")
                 .then { playlist_repository.find_or_create(**it.symbolize_keys) }
        end

        def process playlist, records
          records.each do |record|
            logger.info { "Processing #{record.path}..." }
            upsert playlist, record
          end

          records
        end

        def update_current_item playlist
          playlist_id = playlist.id
          current_item = item_repository.first playlist_id: playlist_id

          return unless current_item

          playlist_repository.update playlist_id, current_item_id: current_item.id
        end

        def upsert playlist, record
          upsert_screen(record).fmap { |screen| add_to_playlist playlist.id, screen, record }
                               .then { log it }
        end

        # :reek:FeatureEnvy
        def upsert_screen record
          name = record.fetch("model", Core::EMPTY_HASH)["name"]
          model = model_repository.find_by(name:)

          return Failure "Unknown model: #{name}." unless model

          upserter.call model_id: model.id,
                        label: record.label,
                        name: record.name,
                        uri: record.path.to_s,
                        mode: record.fetch("screen", Core::EMPTY_HASH).fetch("mode", "text")
        end

        def add_to_playlist id, screen, record
          item_repository.create playlist_id: id, screen_id: screen.id, position: record.position
          screen
        end

        def log result
          case result
            in Success(screen)
              logger.info { "Upserted screen: #{screen.label} (#{screen.id})." }
            in Failure(message) then logger.error { message }
          end
        end
      end
    end
  end
end
