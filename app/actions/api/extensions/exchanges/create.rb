# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        module Exchanges
          # The create action.
          class Create < Base
            include Deps["aspects.extensions.exchanges.creator"]
            include Initable[serializer: Serializers::Extensions::Exchange]

            using Refines::Actions::Response

            params do
              required(:extension_id).filled :integer
              required(:exchange).filled :hash, Schemas::Extensions::Exchanges::Create
            end

            def handle request, response
              case creator.call request.params.to_h, validator: contract
                in Success(extension) then success extension, response
                in Failure(result) then failure result, response
              end
            end

            private

            def success extension, response
              response.with body: {data: serializer.new(extension).to_h}.to_json
            end

            def failure result, response
              response.with_details problem[
                type: "/problem_details#extension_exchange",
                status: :unprocessable_content,
                detail: translate("api.shared.errors.validation"),
                instance: "/api/extensions/#{result[:extension_id]}/exchanges",
                extensions: {errors: result.errors.to_h}
              ]
            end
          end
        end
      end
    end
  end
end
