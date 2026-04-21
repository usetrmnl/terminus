# frozen_string_literal: true

require "dry/monads"
require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Screens
      # Initializes and builds a screen mold.
      class MoldBuilder
        include Deps["aspects.models.finder", :logger, palette_repository: "repositories.palette"]
        include Initable[mold: Mold, fallbacks: {grays: 0, color_codes: []}]
        include Dry::Monads[:result]

        using Refinements::Hash

        def call model_id: nil, device_id: nil, **attributes
          finder.call(model_id:, device_id:)
                .fmap { |model| palette_attributes_for model }
                .fmap { |model, palette| build model, palette, attributes }
                .fmap { log_debug it }
        end

        private

        def palette_attributes_for model
          palette = palette_repository.find model.default_palette_id
          attributes = palette ? palette.screen_attributes : fallbacks

          [model, attributes]
        end

        def build model, palette_attributes, attributes
          allowed_keys = mold.members

          mold.new(
            **model.to_h.transform_keys!(id: :model_id).slice(*allowed_keys),
            **palette_attributes,
            **attributes.slice(*allowed_keys)
          )
        end

        def log_debug record
          logger.debug(tags: record.to_h) { "Screen mold built." }
          record
        end
      end
    end
  end
end
