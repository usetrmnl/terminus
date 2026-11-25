# frozen_string_literal: true

module Terminus
  module Actions
    module Firmware
      # The index action.
      class Index < Action
        include Deps[:htmx, :htmx_layout, repository: "repositories.firmware"]

        protected

        def handle request, response
          query = request.params[:query]
          firmware = load query

          if htmx.request? request.env, :source, "input#search"
            add_htmx_headers response, query
            response.render view, firmware:, query:, layout: htmx_layout.call(request)
          else
            response.render view, firmware:, query:
          end
        end

        private

        def load(query) = query ? repository.search(:version, query) : repository.all

        def add_htmx_headers response, query
          htmx.response! response.headers, push_url: routes.path(:firmwares, query:)
        end
      end
    end
  end
end
