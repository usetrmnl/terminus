# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        module Exchanges
          # The show action.
          class Show < Base
            include Deps[repository: "repositories.extension_exchange"]
            include Initable[serializer: Serializers::Extensions::Exchange]

            def handle request, response
              extension_id, id = request.params.to_h.values_at :extension_id, :id
              exchange = repository.find_by(extension_id:, id:)

              response.body = if exchange
                                {data: serializer.new(exchange).to_h}.to_json
                              else
                                problem[status: :not_found].to_json
                              end
            end
          end
        end
      end
    end
  end
end
