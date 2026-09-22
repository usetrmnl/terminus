# frozen_string_literal: true

require "core"

module Terminus
  module Actions
    module API
      module Extensions
        module Exchanges
          # The index action.
          class Index < Base
            include Deps[repository: "repositories.extension_exchange"]
            include Initable[serializer: Serializers::Extensions::Exchange]

            def handle request, response
              response.body = {data: load_data(request.params[:extension_id])}.to_json
            end

            private

            def load_data extension_id
              repository.where(extension_id:).map { serializer.new(it).to_h }
            end
          end
        end
      end
    end
  end
end
