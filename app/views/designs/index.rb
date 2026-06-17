# frozen_string_literal: true

module Terminus
  module Views
    module Designs
      # The index view.
      class Index < View
        expose :templates
        expose :query
      end
    end
  end
end
