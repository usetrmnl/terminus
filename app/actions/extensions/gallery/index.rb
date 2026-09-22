# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Gallery
        # The index action.
        class Index < Action
          include Deps["aspects.errors.detailer", :htmx, trmnl_api: :trmnl_api_recipes]
          include Initable[empty_recipe: proc { TRMNL::API::Models::Recipe.empty }]

          params do
            optional(:query).filled :string
            optional(:page).filled :integer
          end

          def handle request, response
            parameters = request.params

            case load parameters
              in Success(recipe) then render request, recipe, response
              in Failure(String => message) then render_error parameters, message, response
              in Failure(Dry::Schema::Result => result)
                render_errors result, parameters, response
              else
                response.flash.now[:alert] = translate ".alert"
                response.render view, recipe: empty_recipe, **parameters.to_h.slice(:query, :page)
            end
          end

          private

          def load parameters
            case parameters
              in query:, page: then trmnl_api.recipes(search: query, page:)
              in query: then trmnl_api.recipes search: query
              in page: then trmnl_api.recipes(page:)
              else trmnl_api.recipes
            end
          end

          def render request, recipe, response
            query, page = request.params.to_h.values_at :query, :page

            if htmx.request(**request.env).request?
              htmx.response! response.headers,
                             push_url: routes.path(:extensions_gallery, query:, page:)
              response.render view, recipe:, query:, page:, layout: false
            else
              response.render view, recipe:, query:, page:
            end
          end

          def render_error parameters, message, response
            response.flash.now[:alert] = message
            response.render view, recipe: empty_recipe, **parameters.to_h.slice(:query, :page)
          end

          def render_errors result, parameters, response
            response.flash.now[:alert] = detailer.call result, "Gallery "
            response.render view, recipe: empty_recipe, **parameters.to_h.slice(:query, :page)
          end
        end
      end
    end
  end
end
