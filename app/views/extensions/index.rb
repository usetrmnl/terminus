# frozen_string_literal: true

module Terminus
  module Views
    module Extensions
      # The index view.
      class Index < Hanami::View
        expose :extensions, decorate: true
        expose :query
      end
    end
  end
end
