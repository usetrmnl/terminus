# frozen_string_literal: true

module Terminus
  module Views
    module Playlists
      # The index view.
      class Index < View
        expose :playlists, decorate: true
        expose :query
      end
    end
  end
end
