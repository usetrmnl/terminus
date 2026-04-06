# frozen_string_literal: true

module Terminus
  module Views
    module Extensions
      module Exchanges
        # The index view.
        class Index < View
          expose :extension
          expose :exchanges
        end
      end
    end
  end
end
