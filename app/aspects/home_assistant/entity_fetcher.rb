# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module HomeAssistant
      # Fetches one or many entity state payloads.
      class EntityFetcher
        include Deps["aspects.home_assistant.client", "aspects.home_assistant.url_normalizer"]
        include Dry::Monads[:result]

        def call connection, entity_ids:, normalize_urls: true
          ids = normalized_ids entity_ids
          return Failure "Home Assistant entity IDs are missing." if ids.empty?

          fetch_all connection, ids, normalize_urls:
        end

        private

        def normalized_ids entity_ids
          Array(entity_ids).map { it.to_s.strip }
                           .reject(&:empty?)
        end

        def fetch_all connection, ids, normalize_urls:
          records = ids.each_with_object [] do |entity_id, all|
            payload = fetch_one connection, entity_id, normalize_urls: normalize_urls
            return payload if payload.failure?

            all << payload.value!
          end

          Success records
        end

        def fetch_one connection, entity_id, normalize_urls:
          result = client.call connection, "/api/states/#{entity_id}"
          return result if result.failure?

          payload = result.value!
          payload = url_normalizer.call(payload, connection.base_url) if normalize_urls
          Success payload
        end
      end
    end
  end
end
