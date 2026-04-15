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
            fetcher: "aspects.extensions.fetchers.sole",
            extension_repository: "repositories.extension",
            exchange_repository: "repositories.extension_exchange"
          ]
          include Initable[input: Fetchers::Input]
          include Dry::Monads[:result]

          def call exchange
            extension_id = exchange.extension_id
            extension = extension_repository.find extension_id

            return Failure "Unable to find extension by ID: #{extension_id}." unless extension

            update exchange, build_inputs(exchange, extension)
          end

          private

          def build_inputs exchange, extension
            uri_builder.call(exchange.template, extension.data).map do |uri|
              input[uri:, **exchange.http_attributes]
            end
          end

          def update exchange, inputs
            id = exchange.id
            payloads = fetch inputs

            exchange_repository.update id, **payloads, refreshed_at: Time.now
            Success exchange_repository.find id
          end

          # :reek:FeatureEnvy
          # :reek:TooManyStatements
          def fetch inputs, data: {}, errors: {}
            inputs.each.with_index 1 do |input, index|
              key = "source_#{index}"

              case fetcher.call input
                in Success(payload) then data.merge! key => payload[:data]
                in Failure(payload) then errors.merge! key => payload[:error]
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
