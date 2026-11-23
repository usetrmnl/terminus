# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      # The new action.
      class New < Action
        include Deps[:htmx_layout]

        def initialize(defaults: Aspects::Extensions::DEFAULTS, **)
          @defaults = defaults
          super(**)
        end

        protected

        def handle request, response
          response.render view, fields: defaults, layout: htmx_layout.call(request)
        end

        private

        attr_reader :defaults
      end
    end
  end
end
