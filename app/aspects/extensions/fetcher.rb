# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      # Processes a single HTTP exchange.
      class Fetcher
        include Deps[:http, repository: "repositories.extension_exchange"]
        include Initable[parser: Extensions::Parser, special_header: "Accept"]
        include Dry::Monads[:result]

        def call exchange
          request(exchange).fmap { maybe_alter_mime_type exchange.headers, it }
                           .fmap { |mime_type, body| parse mime_type, body }
                           .bind { save_success exchange, it }
        end

        private

        def request exchange
          http.headers(exchange.headers)
              .public_send(exchange.verb, exchange.uri)
              .then { it.status.success? ? Success(it) : save_failure(exchange, it) }
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

        def save_success exchange, result
          id = exchange.id

          if result.success?
            repository.update id, data: result.success
            Success repository.find(id)
          else
            repository.update id, error_status: nil, error_type: nil, error_body: result.failure
            Failure repository.find(id)
          end
        end

        def save_failure exchange, error
          id = exchange.id
          repository.update id,
                            error_code: error.code,
                            error_type: error.mime_type,
                            error_body: error.body

          Failure repository.find(id)
        end
      end
    end
  end
end
