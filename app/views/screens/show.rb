# frozen_string_literal: true

module Terminus
  module Views
    module Screens
      # The show view.
      class Show < View
        expose :screen, decorate: true
      end
    end
  end
end
