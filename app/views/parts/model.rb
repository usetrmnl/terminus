# frozen_string_literal: true

require "hanami/view"
require "initable"
require "refinements/array"

module Terminus
  module Views
    module Parts
      # The model presenter.
      class Model < Hanami::View::Part
        include Deps[
          join_repository: "repositories.model_palette",
          palette_repository: "repositories.palette"
        ]
        include Initable[json_formatter: Aspects::JSONFormatter]

        using Refinements::Array

        def allowed_palettes
          join_repository.where(model_id: id)
                         .map(&:palette_id)
                         .then { |ids| palette_repository.where(id: ids) }
                         .map(&:name)
                         .then { it.empty? ? ["All"] : it }
                         .to_sentence
        end

        def default_palette_name = default_palette_id ? default_palette.name : "None"

        def dimensions = "#{width}x#{height}"

        def formatted_css = json_formatter.call css

        def kind_label
          case kind
            when "byod", "trmnl" then kind.upcase
            else kind.capitalize
          end
        end
      end
    end
  end
end
