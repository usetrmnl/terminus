# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Devices
        # The delete action.
        class Delete < Base
          include Deps["aspects.devices.deleter"]
          include Initable[serializer: Serializers::Device]

          using Refines::Actions::Response

          def handle request, response
            device = deleter.call request.params[:id]

            if device
              response.with body: {data: serializer.new(device).to_h}.to_json
            else
              response.with_details problem[status: :not_found]
            end
          end
        end
      end
    end
  end
end
