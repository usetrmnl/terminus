# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The delete action.
        class Delete < Action
          include Deps["aspects.extensions.exchanges.deleter"]

          params do
            required(:extension_id).filled :integer
            required(:id).filled :integer
          end

          using Terminus::Refines::Actions::Response

          def handle request, response
            case deleter.call request.params.to_h, validator: contract
              in Success then response.with body: ""
              else halt :unprocessable_content
            end
          end
        end
      end
    end
  end
end
