# frozen_string_literal: true

module Terminus
  module Contracts
    module Extensions
      module Exchanges
        # The contract for extension exchange updating.
        class Update < Contract
          params do
            required(:extension_id).filled :integer
            required(:id).filled :integer
            required(:exchange).filled Schemas::Extensions::Exchanges::Upsert
          end
        end
      end
    end
  end
end
