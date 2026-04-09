# frozen_string_literal: true

require "dry/core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      # Processes multiple HTTP exchanges.
      class MultiFetcher
        include Deps[
          "aspects.extensions.fetcher",
          exchange_repository: "repositories.extension_exchange"
        ]
        include Dry::Monads[:result]

        def call extension
          exchanges = exchange_repository.where extension_id: extension.id
          exchanges.one? ? fetch_sole(exchanges) : fetch_many(exchanges)
        end

        private

        def fetch_sole exchanges
          fetcher.call(exchanges.first).fmap { {"source" => it.data} }
                                       .or { Success Dry::Core::EMPTY_HASH }
        end

        def fetch_many exchanges
          data = exchanges.each.with_index(1).with_object({}) do |(exchange, index), all|
            fetcher.call(exchange).bind { all["source_#{index}"] = it.data }
          end

          Success data
        end
      end
    end
  end
end
