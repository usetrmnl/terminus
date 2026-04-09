# frozen_string_literal: true

require "dry/core"
require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Renderers
        # Uses Liquid template to render poll data.
        class Poll
          include Deps[
            "aspects.extensions.exchanges.refresher",
            exchange_repository: "repositories.extension_exchange",
            renderer: "liquid.default"
          ]
          include Dry::Monads[:result]
          include Initable[coalescer: proc { Terminus::Aspects::Extensions::Exchanges::Coalescer }]

          def call extension, context: Dry::Core::EMPTY_HASH
            refresh extension.id
            render extension, context
          end

          private

          def refresh extension_id
            exchange_repository.where(extension_id:).each { refresher.call it }
          end

          def render extension, context
            exchanges = exchange_repository.where extension_id: extension.id
            data = coalescer.call exchanges

            Success renderer.call(extension.template, context.merge(data))
          end
        end
      end
    end
  end
end
