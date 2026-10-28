# frozen_string_literal: true

require "dry/monads"
require "initable"
require "uri"

module Terminus
  module Aspects
    # A simple content downloader.
    class Downloader
      include Deps[:http, :logger]
      include Initable[
        allowed_domains: %w[trmnl.com trmnl-fw.s3.us-east-2.amazonaws.com],
        parser: URI
      ]
      include Dry::Monads[:result]

      def call raw_uri
        uri = parser.parse raw_uri.to_s

        check(uri).bind { get uri }
                  .tap { log it, uri }
      end

      private

      def check uri
        return Failure "Invalid scheme (use HTTPS): #{uri}." unless uri.scheme == "https"
        return Success() if allowed_domains.empty?

        allowed_domains.any? { uri.host == it }
                       .then { it ? Success() : Failure("Blocked domain: #{uri}.") }
      end

      def get uri
        http.get(uri).then do |response|
          response.status.success? ? Success(response) : Failure(response)
        end
      rescue HTTP::RequestError, OpenSSL::SSL::SSLError => error
        Failure error.message
      end

      def log result, uri
        case result
          in Success then logger.info { "Downloaded: #{uri}." }
          in Failure(HTTP::Response => response) then log_error response.body.to_s
          in Failure(String => message) then log_error message
          else log_error "Unable to download: #{uri.inspect}."
        end

        result
      end

      def log_error(message) = logger.error { message }
    end
  end
end
