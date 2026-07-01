# frozen_string_literal: true

module Terminus
  module Views
    module Devices
      # The show view.
      class Show < View
        expose :device, decorate: true
      end
    end
  end
end
