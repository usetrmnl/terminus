# frozen_string_literal: true

module Terminus
  module Views
    module Screens
      # The index view.
      class Index < Hanami::View
        expose :screens, decorate: true
        expose :query
      end
    end
  end
end
