# frozen_string_literal: true

module Terminus
  module Views
    module Extensions
      module Gallery
        # The index view.
        class Index < Hanami::View
          expose :recipe
          expose :query
          expose :page
        end
      end
    end
  end
end
