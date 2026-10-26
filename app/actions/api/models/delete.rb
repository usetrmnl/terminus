# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Models
        # The delete action.
        class Delete < Base
          include Deps[repository: "repositories.model"]
          include Initable[serializer: Serializers::Model]

          using Refines::Actions::Response

          def handle request, response
            model = repository.delete request.params[:id]

            if model
              response.with body: {data: serializer.new(model).to_h}.to_json
            else
              response.with_details problem[status: :not_found]
            end
          end
        end
      end
    end
  end
end
