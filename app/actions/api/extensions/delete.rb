# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The delete action.
        class Delete < Base
          include Deps[repository: "repositories.extension"]
          include Initable[serializer: Serializers::Extension]

          using Refines::Actions::Response

          def handle request, response
            repository.find(request.params[:id]).then do |extension|
              extension ? success(extension, response) : failure(response)
            end
          end

          private

          def success extension, response
            repository.delete extension.id
            response.body = {data: serializer.new(extension).to_h}.to_json
          end

          def failure(response) = response.with_details problem[status: :not_found]
        end
      end
    end
  end
end
