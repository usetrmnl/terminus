# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Firmware
        # The delete action.
        class Delete < Base
          include Deps[repository: "repositories.firmware"]
          include Initable[serializer: Serializers::Firmware]

          using Refines::Actions::Response

          protected

          def handle request, response
            repository.find(request.params[:id]).then do |firmware|
              firmware ? success(firmware, response) : failure(response)
            end
          end

          private

          def success firmware, response
            repository.delete firmware.id
            response.body = {data: serializer.new(firmware).to_h}.to_json
          end

          def failure(response) = response.with_details problem[status: :not_found]
        end
      end
    end
  end
end
