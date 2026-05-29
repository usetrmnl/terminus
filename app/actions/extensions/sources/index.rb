# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Sources
        # The index action.
        class Index < Action
          include Deps[
            :htmx_layout,
            repository: "repositories.extension_exchange",
            extension_repository: "repositories.extension",
            connection_repository: "repositories.home_assistant_connection",
            config_repository: "repositories.extension_home_assistant_config",
            entity_fetcher: "aspects.home_assistant.entity_fetcher",
            endpoint_fetcher: "aspects.home_assistant.endpoint_fetcher",
            logger: "logger"
          ]

          params { required(:extension_id).filled :integer }

          def initialize(
            coalescer: Aspects::Extensions::Exchanges::Coalescer,
            json_formatter: Aspects::JSONFormatter,
            **
          )
            @coalescer = coalescer
            @json_formatter = json_formatter
            super(**)
          end

          # rubocop:disable Metrics/AbcSize
          def handle request, response
            extension = extension_repository.find request.params[:extension_id]
            halt :not_found unless extension

            content = if extension.kind == "home_assistant"
                        json_formatter.call home_assistant_sources(extension.id)
                      else
                        exchanges = repository.where extension_id: request.params[:extension_id]
                        json_formatter.call coalescer.call(exchanges)
                      end

            response.render view, content:, layout: htmx_layout.call(request)
          end
          # rubocop:enable Metrics/AbcSize

          private

          attr_reader :coalescer, :json_formatter

          # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
          def home_assistant_sources extension_id
            connection = connection_repository.current
            config = config_repository.find_by_extension_id extension_id: extension_id
            unless config
              return {error: "Home Assistant configuration is missing for this extension."}
            end

            case config.source_mode
              when "entity"
                entity_result = entity_fetcher.call(
                  connection,
                  entity_ids: config.entity_ids,
                  normalize_urls: config.normalize_urls
                )
                return {error: entity_result.failure} if entity_result.failure?

                entities = entity_result.value!
                entity_map = entities.to_h { |item| [item["entity_id"], item] }
                aliases = build_aliases entity_map, config.attribute_map
                {
                  source: entities.one? ? entities.first : entities,
                  entities: entities,
                  entity_map: entity_map,
                  aliases: aliases,
                  ha: aliases,
                  home_assistant: {
                    entities: entities,
                    entity_map: entity_map,
                    aliases: aliases
                  }
                }
              when "endpoint"
                endpoint_result = endpoint_fetcher.call(
                  connection,
                  endpoint_path: config.endpoint_path,
                  normalize_urls: config.normalize_urls
                )
                return {error: endpoint_result.failure} if endpoint_result.failure?

                {source: endpoint_result.value!}
              else
                {error: "Unsupported Home Assistant source mode: #{config.source_mode}."}
            end
          rescue StandardError => error
            logger.error "Home Assistant sources failed: #{error.class}: #{error.message}"
            {error: "Unable to load Home Assistant sources right now."}
          end
          # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

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
