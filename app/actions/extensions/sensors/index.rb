# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      module Sensors
        # The index action.
        class Index < Action
          include Deps[
            :htmx_layout,
            repository: "repositories.extension",
            sensor_repository: "repositories.device_sensor"
          ]
          include Initable[json_formatter: Aspects::JSONFormatter]

          using Refinements::Hash

          params { required(:extension_id).filled :integer }

          protected

          def handle request, response
            extension = repository.find request.params[:extension_id]

            halt :not_found unless extension

            content = load_content extension

            response.render view,
                            content: json_formatter.call(content),
                            layout: htmx_layout.call(request)
          end

          def load_content extension
            device_ids = extension.devices.map(&:id)
            sensors = sensor_repository.limited_where device_id: device_ids
            {sensors: sensors.map(&:liquid_attributes)}
          end
        end
      end
    end
  end
end
