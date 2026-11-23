# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Screens
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.screen"]
          include Initable[serializer: Serializers::Screen]

          protected

          def handle request, response
            screen = repository.find request.params[:id]

            response.body = if screen
                              {data: serializer.new(screen).to_h}.to_json
                            else
                              problem[status: :not_found].to_json
                            end
          end
        end
      end
    end
  end
end
