# auto_register: false
# frozen_string_literal: true

require "hanami/view"

module Terminus
  module Views
    # The application custom view context.
    class Context < Hanami::View::Context
      include Deps[:htmx, :htmx_defaults]

      def htmx? = htmx.request? request.env, :request, "true"

      def htmx_configuration
        content_for(:htmx_merge).then { it ? htmx_defaults.merge(it) : htmx_defaults }
                                .to_json
      end
    end
  end
end
