# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The new action.
      class New < Action
        include Deps[:htmx_layout]

        protected

        def initialize(defaults: Aspects::Models::DEFAULTS, **)
          @defaults = defaults
          super(**)
        end

        def handle request, response
          response.render view, fields: defaults, layout: htmx_layout.call(request)
        end

        private

        attr_reader :defaults
      end
    end
  end
end
