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

        def handle request, response
          parameters = request.params

          case process parameters
            in Success
              response.render index_view, devices: repository.all, layout: htmx_layout.call(request)
            else error response, parameters
          end
        end

        private

        def process parameters
          parameters.valid? ? creator.call(**parameters[:device]) : Failure
        end

        def error response, parameters
          response.render view,
                          models: model_repository.all,
                          playlists: playlist_repository.all,
                          device: nil,
                          fields: parameters[:device],
                          errors: parameters.errors[:device],
                          layout: false
        end
      end
    end
  end
end
