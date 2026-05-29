# frozen_string_literal: true

require "dry/monads"
require "json"

module Terminus
  module Aspects
    module HomeAssistant
      # Performs authenticated requests against Home Assistant REST API.
      class Client
        include Deps[:http]
        include Dry::Monads[:result]

        def call connection, path, require_enabled: true
          fetch(connection, path, require_enabled:).bind do |response|
            parse_response response, path
          end
        end

        def fetch connection, path, require_enabled: true
          validation = validate_connection connection, require_enabled: require_enabled

          return validation if validation.failure?

          response = request connection, path
          return build_failure response unless response.status.success?

          Success response
        rescue HTTP::RequestError, HTTP::ConnectionError
          Failure "Home Assistant is unreachable."
        rescue HTTP::TimeoutError
          Failure "Home Assistant request timed out."
        end

        private

        def validate_connection connection, require_enabled:
          return Failure "Home Assistant not configured." unless connection
          return Failure "Home Assistant is disabled." if require_enabled && !connection.enabled

          token = String connection.access_token
          return Failure "Home Assistant access token is missing." if token.empty?

          Success()
        end

        def request connection, path
          http.headers("Authorization" => "Bearer #{connection.access_token}")
              .follow
              .get(build_uri(connection.base_url, path))
        end

        def normalized_base_url base_url
          value = String(base_url).strip
          value = "http://#{value}" unless value.match? %r(\Ahttps?://)i
          value.sub %r(/+\z), ""
        end

        def normalized_path path
          value = String(path).strip
          value.start_with?("/") ? value : "/#{value}"
        end

        def build_uri base_url, path
          [normalized_base_url(base_url), normalized_path(path)].join
        end

        def parse_response response, path
          body = response.to_s
          data = body.empty? ? {} : JSON.parse(body)
          Success data
        rescue JSON::ParserError
          Failure "Home Assistant returned invalid JSON for #{normalized_path path}."
        end

        def build_failure response
          case response.code
            when 401 then Failure("Home Assistant unauthorized (401).")
            when 404 then Failure("Home Assistant resource not found (404).")
            else Failure "Home Assistant request failed (#{response.code})."
          end
        end
      end
    end
  end
end
