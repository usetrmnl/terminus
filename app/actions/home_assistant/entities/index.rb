# frozen_string_literal: true

module Terminus
  module Actions
    module HomeAssistant
      module Entities
        # Lists Home Assistant entities for extension form discovery.
        class Index < Action
          include Deps[
            connection_repository: "repositories.home_assistant_connection",
            client: "aspects.home_assistant.client",
            logger: "logger"
          ]

          params do
            optional(:query).maybe :string
            optional(:entity_ids).maybe :string
          end

          # rubocop:disable Metrics/AbcSize
          def handle request, response
            connection = connection_repository.current
            result = client.call connection, "/api/states", require_enabled: false

            return handle_failure response, result.failure if result.failure?

            entities = filter result.value!, request.params[:query], request.params[:entity_ids]
            payload = entities.first(200).map { |entity| simplify entity }
            render_payload response, payload
          end
          # rubocop:enable Metrics/AbcSize

          private

          def render_error response, message
            response.status = 422
            response.headers["Content-Type"] = "application/json"
            response.body = {error: message, data: []}.to_json
          end

          def handle_failure response, message
            logger.warn "Home Assistant entity discovery failed: #{message}"
            render_error response, message
          end

          def render_payload response, payload
            response.headers["Content-Type"] = "application/json"
            response.body = {data: payload}.to_json
          end

          def filter entities, query, entity_ids
            ids = parse_entity_ids entity_ids
            scoped = scoped_entities entities, ids

            term = String(query).strip.downcase
            return scoped if term.empty?

            scoped.select { |entity| matches_term? entity, term }
          end

          def parse_entity_ids entity_ids
            String(entity_ids).split(",").map(&:strip).reject(&:empty?)
          end

          def scoped_entities entities, ids
            all_entities = Array entities
            return all_entities if ids.empty?

            all_entities.select { |entity| ids.include? entity["entity_id"].to_s }
          end

          def matches_term? entity, term
            [
              entity["entity_id"],
              entity.dig("attributes", "friendly_name"),
              entity["state"]
            ].map { it.to_s.downcase }
             .any? { it.include? term }
          end

          def simplify entity
            {
              "entity_id" => entity["entity_id"],
              "friendly_name" => entity.dig("attributes", "friendly_name"),
              "state" => entity["state"],
              "domain" => entity["entity_id"].to_s.split(".").first,
              "attributes" => entity["attributes"] || {}
            }
          end
        end
      end
    end
  end
end
