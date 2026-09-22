# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.extension"]
          include Initable[serializer: Serializers::Extension]

          def handle request, response
            extension = repository.find request.params[:id]

            response.body = if extension
                              {data: serializer.new(extension).to_h}.to_json
                            else
                              problem[status: :not_found].to_json
                            end
          end
        end
      end
    end
  end
end
