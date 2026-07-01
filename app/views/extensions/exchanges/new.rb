# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Extensions
      module Exchanges
        # The new view.
        class New < View
          expose :extension
          expose :exchange
          expose :fields, default: Core::EMPTY_HASH
          expose :errors, default: Core::EMPTY_HASH
        end
      end
    end
  end
end
