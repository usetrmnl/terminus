# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Screens
        # The delete action.
        class Delete < Base
          include Deps[repository: "repositories.screen"]
          include Initable[serializer: Serializers::Screen]

          using Refines::Actions::Response

          protected

          def handle request, response
            repository.find(request.params[:id]).then do |screen|
              screen ? success(screen, response) : failure(response)
            end
          end

          private

          def success screen, response
            repository.delete screen.id
            response.body = {data: serializer.new(screen).to_h}.to_json
          end

          def failure(response) = response.with_details problem[status: :not_found]
        end
      end
    end
  end
end
