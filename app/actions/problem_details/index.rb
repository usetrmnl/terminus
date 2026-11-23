# frozen_string_literal: true

module Terminus
  module Actions
    module ProblemDetails
      # The index action.
      class Index < Action
        protected

        def handle(_request, response) = response.render view
      end
    end
  end
end
