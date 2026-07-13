# frozen_string_literal: true

require "dry/core"
require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Exchanges
        # Updates an exchange based on multiple responses.
        class Refresher
          include Deps[
            "aspects.extensions.uri_builder",
            "aspects.extensions.fetchers.client",
            extension_repository: "repositories.extension",
            exchange_repository: "repositories.extension_exchange"
          ]
          include Initable[request: Fetchers::Request]
          include Dry::Monads[:result]

          def call exchange
            extension_id = exchange.extension_id
            extension = extension_repository.find extension_id

            return Failure "Unable to find extension by ID: #{extension_id}." unless extension

            update exchange, build_requests(exchange, extension)
          end

          private

          def build_requests exchange, extension
            uri_builder.call(extension, exchange.template).map do |uri|
              request[uri:, **exchange.http_attributes]
            end
          end

          def update exchange, requests
            id = exchange.id
            payloads = fetch requests, data: exchange.data.dup

            exchange_repository.update id, **payloads, refreshed_at: Time.now
            Success exchange_repository.find id
          end

          def fetch requests, data:, errors: {}
            requests.each.with_index 1 do |request, index|
              key = "source_#{index}"

              case client.call request
                in Success(response) then response.merge_data key, data
                in Failure(response) then response.merge_errors key, errors
                else errors.merge! key => "Unable to fetch, invalid result."
              end
            end

            {data:, errors:}
          end
        end
      end
    end
  end
end
