# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Playlists
      # The edit view.
      class Edit < View
        expose :playlist
        expose :items, default: Core::EMPTY_ARRAY
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end
