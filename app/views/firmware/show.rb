# frozen_string_literal: true

module Terminus
  module Views
    module Firmware
      # The show view.
      class Show < View
        expose :firmware
        expose :models
      end
    end
  end
end
