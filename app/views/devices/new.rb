# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Devices
      # The new view.
      class New < View
        expose :models
        expose :playlists
        expose :device
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end
