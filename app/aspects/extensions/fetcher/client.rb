# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Fetcher
        # A specialized client for processing HTTP requests.
        class Client
          include Deps[:http]
          include Initable[source: Extensions::Source, special_header: "accept", response: Response]
          include Dry::Monads[:result]

          def call request
            resolve(request).fmap { maybe_alter_mime_type request.headers, it }
                            .fmap { |mime_type, body| parse mime_type, body }
                            .bind { build_success request, it }
          end

          private

          def resolve request
            process request
          rescue HTTP::RequestError then build_failure request, "Unable to make request"
          rescue HTTP::ConnectionError then build_failure request, "Unable to connect"
          rescue HTTP::TimeoutError then build_failure request, "Connection timed out"
          rescue OpenSSL::SSL::SSLError then build_failure request, "Unable to secure connection"
          end

          def process request
            http.headers(request.headers)
                .follow
                .public_send(request.verb, request.uri, **request.http_options)
                .then { it.status.success? ? Success(it) : build_detailed_failure(request, it) }
          end

          def maybe_alter_mime_type headers, response
            type = headers && headers.transform_keys(&:downcase)[special_header]
            [type || response.mime_type, response.body]
          end

          def parse type, body
            case type
              when %r(application/([[:alnum:]][\w!#&\-^$]*\+)?json) then source.from_json body
              when %r(image/.+) then source.from_image body
              when "text/calendar" then source.from_calendar body
              when "text/csv" then source.from_csv body
              when "text/plain" then source.from_text body
              when "text/xml", "application/xml", "application/rss+xml", "application/atom+xml"
                source.from_xml body
              else Failure "Unknown MIME Type: #{type}."
            end
          end

          def build_success request, result
            if result.success?
              Success response[data: result.success]
            else
              build_failure request, result.failure
            end
          end

          def build_failure request, body
            Failure response[errors: {uri: request.uri, code: nil, type: nil, body:}]
          end

          def build_detailed_failure request, error
            Failure response[
              errors: {uri: request.uri, code: error.code, type: error.mime_type, body: error.body}
            ]
          end
        end
      end
    end
  end
end
