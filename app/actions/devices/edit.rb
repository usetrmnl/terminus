# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The edit action.
      class Edit < Action
        include Deps[
          :htmx_layout,
          repository: "repositories.device",
          model_repository: "repositories.model",
          playlist_repository: "repositories.playlist"
        ]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          response.render view, **view_settings(request, parameters)
        end

        private

        def view_settings request, parameters
          {
            models: model_repository.all,
            playlists: playlist_repository.all,
            device: repository.find(parameters[:id]),
            layout: htmx_layout.call(request)
          }
        end
      end
    end
  end
end
