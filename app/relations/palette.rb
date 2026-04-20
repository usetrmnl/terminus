# frozen_string_literal: true

module Terminus
  module Relations
    # The palette relation.
    class Palette < DB::Relation
      schema :palette, infer: true do
        associations do
          has_many :model_palettes, relation: :model_palette
          has_many :models, through: :model_palette, relation: :model
        end
      end
    end
  end
end
