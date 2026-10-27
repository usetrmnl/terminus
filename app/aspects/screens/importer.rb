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
          playlist_repostiory: "repositories.playlist"
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
          playlist_id = records.first
                               .fetch("playlist")
                               .then { playlist_repostiory.find_or_create(**it.symbolize_keys) }
                               .id

          item_repository.delete_all(playlist_id:)
          process playlist_id, records
        end

        def process playlist_id, records
          records.each do |record|
            logger.info { "Processing #{record.path}..." }
            upsert playlist_id, record
          end

          records
        end

        def upsert playlist_id, record
          upsert_screen(record).fmap { |screen| add_to_playlist playlist_id, screen, record }
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
