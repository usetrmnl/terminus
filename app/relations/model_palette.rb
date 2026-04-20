# frozen_string_literal: true

module Terminus
  module Relations
    # The model and palette join relation.
    class ModelPalette < DB::Relation
      schema :model_palette, infer: true do
        associations do
          belongs_to :model, relation: :model
          belongs_to :palette, relation: :palette
        end
      end
    end
  end
end
