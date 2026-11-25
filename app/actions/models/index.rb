# frozen_string_literal: true

module Terminus
  module Actions
    module Models
      # The index action.
      class Index < Action
        include Deps[:htmx, :htmx_layout, repository: "repositories.model"]

        protected

        def handle request, response
          query = request.params[:query].to_s
          models = load query

          if htmx.request? request.env, :source, "input#search"
            add_htmx_headers response, query
            response.render view, models:, query:, layout: htmx_layout.call(request)
          else
            response.render view, models:, query:
          end
        end

        private

        def load(query) = query.empty? ? repository.all : repository.search(:label, query)

        def add_htmx_headers response, query
          return if query.empty?

          htmx.response! response.headers, push_url: routes.path(:models, query:)
        end
      end
    end
  end
end
