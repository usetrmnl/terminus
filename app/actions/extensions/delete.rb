# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      # The delete action.
      class Delete < Action
        include Deps["aspects.extensions.deleter"]

        using Terminus::Refines::Actions::Response

        params { required(:id).filled :integer }

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
