# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Fetchers
        # Processes a single request.
        class Sole
          include Deps[:http]
          include Initable[parser: Extensions::Parser, special_header: "Accept"]
          include Dry::Monads[:result]

          def call input
            process(input).fmap { maybe_alter_mime_type input.headers, it }
                          .fmap { |mime_type, body| parse mime_type, body }
                          .bind { build_success input, it }
          end

          private

          def process input
            http.headers(input.headers)
                .follow
                .public_send(input.verb, input.uri)
                .then { it.status.success? ? Success(it) : build_detailed_failure(input, it) }
          rescue HTTP::RequestError then build_failure input, "Unable to make request"
          rescue HTTP::ConnectionError then build_failure input, "Unable to connect"
          rescue HTTP::TimeoutError then build_failure input, "Connection timed out"
          rescue OpenSSL::SSL::SSLError then build_failure input, "Unable to secure connection"
          end

          def maybe_alter_mime_type headers, response
            type = headers && headers[special_header]
            [type || response.mime_type, response.body]
          end

          def parse type, body
            case type
              when %r(application/([[:alnum:]][\w!#&-^$]*\+)?json) then parser.from_json body
              when %r(image/.+) then parser.from_image body
              when "text/csv" then parser.from_csv body
              when "text/plain" then parser.from_text body
              when "text/xml", "application/xml", "application/rss+xml", "application/atom+xml"
                parser.from_xml body
              else Failure "Unknown MIME Type: #{type}."
            end
          end

          # :reek:FeatureEnvy
          def build_success input, result
            if result.success?
              Success data: result.success, error: Core::EMPTY_HASH
            else
              build_failure input, result.failure
            end
          end

          def build_failure input, body
            Failure data: Core::EMPTY_HASH, error: {uri: input.uri, code: nil, type: nil, body:}
          end

          # :reek:FeatureEnvy
          def build_detailed_failure input, error
            Failure data: Core::EMPTY_HASH,
                    error: {
                      uri: input.uri,
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
