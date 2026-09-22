# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        module Exchanges
          # The patch action.
          class Patch < Base
            include Deps["aspects.extensions.exchanges.updater"]
            include Initable[serializer: Serializers::Extensions::Exchange]

            using Refines::Actions::Response

            params do
              required(:extension_id).filled :integer
              required(:id).filled :integer
              required(:exchange).filled :hash, Schemas::Extensions::Exchanges::Patch
            end

            def handle request, response
              case updater.call request.params.to_h, validator: contract
                in Success(extension) then success extension, response
                in Failure(String) then not_found response
                in Failure(result) then unprocessable_content result, response
              end
            end

            private

            def success extension, response
              response.with body: {data: serializer.new(extension).to_h}.to_json
            end

            def not_found(response) = response.with_details problem[status: :not_found]

            def unprocessable_content result, response
              extension_id, id = result.to_h.values_at :extension_id, :id

              response.with_details problem[
                type: "/problem_details#extension_exchange",
                status: :unprocessable_content,
                detail: translate("api.shared.errors.validation"),
                instance: "/api/extensions/#{extension_id}/exchanges/#{id}",
                extensions: {errors: result.errors.to_h}
              ]
            end
          end
        end
      end
    end
  end
end
