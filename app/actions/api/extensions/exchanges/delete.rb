# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        module Exchanges
          # The delete action.
          class Delete < Base
            include Deps["aspects.extensions.exchanges.deleter"]
            include Initable[serializer: Serializers::Extensions::Exchange]

            using Refines::Actions::Response

            params do
              required(:extension_id).filled :integer
              required(:id).filled :integer
            end

            def handle request, response
              case deleter.call request.params.to_h, validator: contract
                in Success(extension) then success extension, response
                else failure response
              end
            end

            private

            def success extension, response
              response.with body: {data: serializer.new(extension).to_h}.to_json
            end

            def failure(response) = response.with_details problem[status: :not_found]
          end
        end
      end
    end
  end
end
