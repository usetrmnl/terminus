# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The create action.
      class Create < Action
        include Deps[
          :htmx_layout,
          "aspects.devices.creator",
          repository: "repositories.device",
          model_repository: "repositories.model",
          playlist_repository: "repositories.playlist",
          index_view: "views.devices.index"
        ]

        contract Contracts::Devices::Create

        protected

        def handle request, response
          parameters = request.params

          case process parameters
            in Success
              response.render index_view, devices: repository.all, layout: htmx_layout.call(request)
            else render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params

          response.render view,
                          models: model_repository.all,
                          playlists: playlist_repository.all,
                          device: nil,
                          fields: parameters[:device],
                          errors: parameters.errors[:device],
                          layout: htmx_layout.call(request)
        end

        private

        def process(parameters) = parameters.valid? ? creator.call(**parameters[:device]) : Failure
      end
    end
  end
end
