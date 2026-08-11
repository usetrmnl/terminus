# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Context
        # The show action.
        class Show < Action
          include Deps[:htmx_layout, repository: "repositories.extension_exchange"]

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
            exchanges = repository.where extension_id: request.params[:extension_id]
            content = json_formatter.call coalescer.call(exchanges)

            response.render view, content:, layout: htmx_layout.call(request)
          end

          private

          attr_reader :coalescer, :json_formatter
        end
      end
    end
  end
end
