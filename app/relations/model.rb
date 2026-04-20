# frozen_string_literal: true

module Terminus
  module Relations
    # The model relation.
    class Model < DB::Relation
      schema :model, infer: true do
        associations do
          belongs_to :default_palette, relation: :palette
          has_many :devices, relation: :device
          has_many :screens, relation: :screen
          has_many :extension_models, relation: :extension_model
          has_many :extensions, through: :extension_model, relation: :extension
          has_many :model_palettes, relation: :model_palette
          has_many :palettes, through: :model_palette, relation: :palette
        end
      end
    end
  end
end
