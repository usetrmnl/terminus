# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      # The index action.
      class Index < Action
        include Deps[:htmx, :htmx_layout, repository: "repositories.extension"]

        protected

        def handle request, response
          query = request.params[:query].to_s
          extensions = load query

          if htmx.request? request.env, :source, "input#search"
            add_htmx_headers response, query
            response.render view, extensions:, query:, layout: htmx_layout.call(request)
          else
            response.render view, extensions:, query:
          end
        end

        private

        def load(query) = query.empty? ? repository.all : repository.search(:label, query)

        def add_htmx_headers response, query
          return if query.empty?

          htmx.response! response.headers, push_url: routes.path(:extensions, query:)
        end
      end
    end
  end
end
