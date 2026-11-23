# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The new action.
      class New < Action
        include Deps[
          :htmx_layout,
          "aspects.devices.defaulter",
          model_repository: "repositories.model",
          playlist_repository: "repositories.playlist"
        ]

        protected

        def handle request, response
          response.render view,
                          models: model_repository.all,
                          playlists: playlist_repository.all,
                          fields: defaulter.call,
                          layout: htmx_layout.call(request)
        end
      end
    end
  end
end
