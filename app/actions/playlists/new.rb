# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      # The new action.
      class New < Action
        include Deps[:htmx_layout]

        protected

        def handle request, response
          response.render view, fields: {mode: :automatic}, layout: htmx_layout.call(request)
        end
      end
    end
  end
end
