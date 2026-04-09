# frozen_string_literal: true

require "dry/core"
require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Fetchers
        # Processes a single HTTP request.
        class Sole
          include Deps[:http]
          include Initable[parser: Extensions::Parser, special_header: "Accept"]
          include Dry::Monads[:result]

          def call request
            process(request).fmap { maybe_alter_mime_type request.headers, it }
                            .fmap { |mime_type, body| parse mime_type, body }
                            .bind { build_success request, it }
          end

          private

          def process request
            http.headers(request.headers)
                .public_send(request.verb, request.uri)
                .then { it.status.success? ? Success(it) : build_failure(request, it) }
          end

          def maybe_alter_mime_type headers, response
            type = headers && headers[special_header]
            [type || response.mime_type, response.body]
          end

          def parse type, body
            case type
              when "application/json" then parser.from_json body
              when %r(image/.+) then parser.from_image body
              when "text/csv" then parser.from_csv body
              when "text/plain" then parser.from_text body
              when "text/xml", "application/xml", "application/rss+xml", "application/atom+xml"
                parser.from_xml body
              else Failure "Unknown MIME Type: #{type}."
            end
          end

          # :reek:FeatureEnvy
          def build_success request, result
            if result.success?
              Success data: result.success, error: Dry::Core::EMPTY_HASH
            else
              Failure data: Dry::Core::EMPTY_HASH,
                      error: {uri: request.uri, code: nil, type: nil, body: result.failure}
            end
          end

          # :reek:FeatureEnvy
          def build_failure request, error
            Failure data: Dry::Core::EMPTY_HASH,
                    error: {
                      uri: request.uri,
                      code: error.code,
                      type: error.mime_type,
                      body: error.body
                    }
          end
        end
      end
    end
  end
end
