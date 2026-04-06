# frozen_string_literal: true

module Terminus
  module Views
    module Extensions
      module Exchanges
        # The new view.
        class New < View
          expose :extension
          expose :exchange
          expose :fields, default: Dry::Core::EMPTY_HASH
          expose :errors, default: Dry::Core::EMPTY_HASH
        end
      end
    end
  end
end
