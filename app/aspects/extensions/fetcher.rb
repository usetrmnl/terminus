# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      # Fetches remote data.
      class Fetcher
        include Deps[:http]
        include Initable[parser: Extensions::Parser, special_header: "Accept"]
        include Dry::Monads[:result]

        def call uri, extension
          request(uri, extension).fmap { maybe_alter_mime_type extension.headers, it }
                                 .bind { |mime_type, body| parse mime_type, body }
        end

        private

        def request uri, extension
          http.headers(extension.headers)
              .public_send(extension.verb, uri)
              .then { it.status.success? ? Success(it) : Failure(it) }
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
      end
    end
  end
end
