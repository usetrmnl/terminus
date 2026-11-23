# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Models
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.model"]
          include Initable[serializer: Serializers::Model]

          protected

          def handle request, response
            model = repository.find request.params[:id]

            response.body = if model
                              {data: serializer.new(model).to_h}.to_json
                            else
                              problem[status: :not_found].to_json
                            end
          end
        end
      end
    end
  end
end
