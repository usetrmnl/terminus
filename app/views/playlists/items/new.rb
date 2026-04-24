# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Playlists
      module Items
        # The new view.
        class New < View
          expose :playlist
          expose :screen_options, decorate: false
          expose :item
          expose :fields, default: Core::EMPTY_HASH
          expose :errors, default: Core::EMPTY_HASH
        end
      end
    end
  end
end
