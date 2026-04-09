# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Sources
        # The index action.
        class Index < Action
          include Deps[:htmx, repository: "repositories.extension_exchange"]

          params { required(:extension_id).filled :integer }

          def initialize(
            coalescer: Aspects::Extensions::Exchanges::Coalescer,
            json_formatter: Aspects::JSONFormatter,
            **
          )
            @coalescer = coalescer
            @json_formatter = json_formatter
            super(**)
          end

          def handle request, response
            response.render view, **view_settings(request)
          end

          private

          attr_reader :coalescer, :json_formatter

          def view_settings request
            exchanges = repository.where extension_id: request.params[:extension_id]
            content = json_formatter.call coalescer.call(exchanges)
            settings = {content:}

            settings[:layout] = false if htmx.request? request.env, :request, "true"
            settings
          end
        end
      end
    end
  end
end
