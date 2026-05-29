# frozen_string_literal: true

require "core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Renderers
        # Uses Liquid template to render static data.
        class Static
          include Deps[renderer: "liquid.sanitize"]
          include Dry::Monads[:result]

          def call extension, context: Core::EMPTY_HASH
            body_context = extension.body.is_a?(Hash) ? extension.body : Core::EMPTY_HASH
            template_context = body_context.merge(context).merge("source_1" => body_context)

            Success renderer.call(extension.template, template_context)
          end
        end
      end
    end
  end
end
