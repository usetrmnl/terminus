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
            Success renderer.call(extension.template, context.merge("source_1" => extension.body))
          end
        end
      end
    end
  end
end
