# frozen_string_literal: true

module Terminus
  module Views
    module Models
      # The show view.
      class Show < View
        expose :model, decorate: true
      end
    end
  end
end
