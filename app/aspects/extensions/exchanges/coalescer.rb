# frozen_string_literal: true

module Terminus
  module Aspects
    module Extensions
      module Exchanges
        # Answers coalesced (and sequenced) data for all exchanges.
        Coalescer = lambda do |exchanges, index: 1|
          exchanges.each.with_object({}) do |exchange, all|
            exchange.data.each do |key, value|
              all[key.sub(/\d+/, index.to_s)] = value
              index += 1
            end
          end
        end
      end
    end
  end
end
