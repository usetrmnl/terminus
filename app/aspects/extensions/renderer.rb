# frozen_string_literal: true

require "dry/monads"
require "refinements/hash"

module Terminus
  module Aspects
    module Extensions
      # Renders extension based on kind.
      class Renderer
        include Deps[
          "aspects.extensions.contextualizer",
          "aspects.extensions.renderers.home_assistant",
          "aspects.extensions.renderers.image",
          "aspects.extensions.renderers.poll",
          "aspects.extensions.renderers.static"
        ]
        include Dry::Monads[:result]

        using Refinements::Hash

        def call extension, model_id: nil, device_id: nil
          process extension, contextualizer.call(extension, model_id:, device_id:)
        end

        private

        def process extension, context
          kind = extension.kind

          case kind
            when "home_assistant" then home_assistant.call extension, context:
            when "image" then image.call extension, context:
            when "poll" then poll.call extension, context:
            when "static" then static.call extension, context:
            else Failure "Unsupported extension kind: #{kind}."
          end
        end
      end
    end
  end
end
