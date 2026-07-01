# frozen_string_literal: true

module Terminus
  module Views
    module Playlists
      module Items
        # The show view.
        class Show < View
          expose :item, decorate: true
        end
      end
    end
  end
end
