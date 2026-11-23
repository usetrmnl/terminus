# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The update action.
      class Update < Action
        include Deps[
          repository: "repositories.device",
          model_repository: "repositories.model",
          playlist_repository: "repositories.playlist",
          show_view: "views.devices.show"
        ]

        contract Contracts::Devices::Update

        protected

        def handle request, response
          parameters = request.params
          device = repository.find parameters[:id]

          halt :unprocessable_content unless device

          if parameters.valid?
            save request, response
          else
            render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params
          device = repository.find parameters[:id]

          response.render view,
                          models: model_repository.all,
                          playlists: playlist_repository.all,
                          device:,
                          fields: parameters[:device],
                          errors: parameters.errors[:device],
                          layout: false
        end

        private

        def save request, response
          parameters = request.params
          id = parameters[:id]

          repository.update id, **parameters[:device]
          response.render show_view, device: repository.find(id), layout: false
        end
      end
    end
  end
end
