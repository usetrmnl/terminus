# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module HomeAssistant
      # Fetches an arbitrary Home Assistant endpoint path.
      class EndpointFetcher
        include Deps["aspects.home_assistant.client", "aspects.home_assistant.url_normalizer"]
        include Dry::Monads[:result]

        def call connection, endpoint_path:, normalize_urls: true
          path = String(endpoint_path).strip
          return Failure "Home Assistant endpoint path is missing." if path.empty?
          return Failure "Home Assistant endpoint path must be relative." if unsafe_path? path

          client.call(connection, path).fmap do |payload|
            normalize_urls ? url_normalizer.call(payload, connection.base_url) : payload
          end
        end

        private

        def unsafe_path? path
          path.match?(%r(\Ahttps?://)i) || !path.start_with?("/")
        end
      end
    end
  end
end
