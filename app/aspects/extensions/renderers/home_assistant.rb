# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Renderers
        # Uses Home Assistant data as source for Liquid rendering.
        class HomeAssistant
          include Deps[
            connection_repository: "repositories.home_assistant_connection",
            config_repository: "repositories.extension_home_assistant_config",
            entity_fetcher: "aspects.home_assistant.entity_fetcher",
            endpoint_fetcher: "aspects.home_assistant.endpoint_fetcher",
            renderer: "liquid.sanitize",
            logger: "logger"
          ]
          include Dry::Monads[:result]

          def call extension, context: {}
            connection = connection_repository.current
            config = config_repository.find_by_extension_id extension_id: extension.id
            unless config
              return Failure "Home Assistant configuration is missing for this extension."
            end

            result = fetch connection, config
            logger.error "Home Assistant fetch failed: #{result.failure}" if result.failure?

            result.fmap { |payload| renderer.call extension.template, context.merge(payload) }
          end

          private

          def fetch connection, config
            case config.source_mode
              when "entity" then fetch_entities(connection, config)
              when "endpoint" then fetch_endpoint(connection, config)
              else Failure "Unsupported Home Assistant source mode: #{config.source_mode}."
            end
          end

          def fetch_entities connection, config
            entity_fetcher.call(
              connection,
              entity_ids: config.entity_ids,
              normalize_urls: config.normalize_urls
            ).fmap { |entities| build_entity_payload entities, config.attribute_map }
          end

          def fetch_endpoint connection, config
            endpoint_fetcher.call(
              connection,
              endpoint_path: config.endpoint_path,
              normalize_urls: config.normalize_urls
            ).fmap { |source| build_endpoint_payload source }
          end

          # rubocop:disable Metrics/MethodLength
          def build_entity_payload entities, attribute_map
            source = entities.one? ? entities.first : entities
            entity_map = entities.to_h { |item| [item["entity_id"], item] }
            aliases = build_aliases entity_map, attribute_map
            home_assistant = {
              "source" => source,
              "entities" => entities,
              "entity_map" => entity_map,
              "aliases" => aliases
            }

            {
              "source" => source,
              "entities" => entities,
              "entity_map" => entity_map,
              "aliases" => aliases,
              "ha" => aliases,
              "home_assistant" => home_assistant
            }
          end
          # rubocop:enable Metrics/MethodLength

          def build_endpoint_payload source
            {
              "source" => source,
              "home_assistant" => {
                "source" => source
              }
            }
          end

          def build_aliases entity_map, attribute_map
            raw_aliases = attribute_map.to_h.fetch("aliases", {})

            raw_aliases.each_with_object({}) do |(name, entity_id), all|
              next if name.to_s.strip.empty?

              entity = entity_map[entity_id.to_s]
              all[name.to_s] = entity if entity
            end
          end
        end
      end
    end
  end
end
