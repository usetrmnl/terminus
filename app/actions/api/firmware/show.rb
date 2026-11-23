# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Firmware
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.firmware"]
          include Initable[serializer: Serializers::Firmware]

          protected

          def handle request, response
            firmware = repository.find request.params[:id]

            response.body = if firmware
                              {data: serializer.new(firmware).to_h}.to_json
                            else
                              problem[status: :not_found].to_json
                            end
          end
        end
      end
    end
  end
end
