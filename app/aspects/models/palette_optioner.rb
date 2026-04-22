# frozen_string_literal: true

require "dry/core"

module Terminus
  module Aspects
    module Models
      # Builds palette selections for use as HTML select options.
      class PaletteOptioner
        include Deps[
          join_repository: "repositories.model_palette",
          palette_repository: "repositories.palette"
        ]

        def call model = nil, prompt: "Select..."
          load_restricted(model).then { it.empty? ? load_all : it }
                                .reduce [[prompt, ""]] do |all, palette|
                                  all.append [palette.label, palette.id]
                                end
        end

        private

        def load_restricted model
          return Dry::Core::EMPTY_ARRAY unless model

          join_repository.where(model_id: model.id)
                         .map(&:palette_id)
                         .then { |ids| palette_repository.where id: ids }
        end

        def load_all = palette_repository.all
      end
    end
  end
end
