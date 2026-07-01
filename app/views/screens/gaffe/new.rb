# frozen_string_literal: true

module Terminus
  module Views
    module Screens
      module Gaffe
        # The new view.
        class New < View
          config.layout = "interrupt"

          expose :message
        end
      end
    end
  end
end
