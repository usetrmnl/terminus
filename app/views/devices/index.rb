# frozen_string_literal: true

module Terminus
  module Views
    module Devices
      # The index view.
      class Index < View
        expose :devices, decorate: true
        expose :query
      end
    end
  end
end
