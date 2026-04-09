# frozen_string_literal: true

require "dry/core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Renderers
        # Uses Liquid template to render images.
        class Image
          include Deps[
            exchange_repository: "repositories.extension_exchange",
            renderer: "liquid.default"
          ]
          include Dry::Monads[:result]

          def call extension, context: Dry::Core::EMPTY_HASH
            exchanges = exchange_repository.where extension_id: extension.id

            if exchanges.one?
              content = renderer.call(
                extension.template,
                {**context, "source_1" => {"url" => exchanges.first.template}}
              )

              Success content
            else
              render_many extension, exchanges, context
            end
          end

          private

          def render_many extension, exchanges, context
            data = exchanges.each.with_index(1).with_object({}) do |(exchange, index), all|
              all["source_#{index}"] = {"url" => exchange.template}
            end

            Success renderer.call(extension.template, context.merge(data))
          end
        end
      end
    end
  end
end
