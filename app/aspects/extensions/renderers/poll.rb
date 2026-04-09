# frozen_string_literal: true

require "dry/core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Renderers
        # Uses Liquid template to render remote data.
        class Poll
          include Deps[fetcher: "aspects.extensions.multi_fetcher", renderer: "liquid.default"]
          include Dry::Monads[:result]

          # :reek:DuplicateMethodCall
          def call extension, context: Dry::Core::EMPTY_HASH
            template = extension.template

            fetcher.call(extension)
                   .either -> data { success template, context.merge(data) },
                           -> data { failure template, context.merge(data) }
          end

          private

          def success(template, data) = Success renderer.call(template, data)

          def failure(template, data) = Failure renderer.call(template, data)
        end
      end
    end
  end
end
