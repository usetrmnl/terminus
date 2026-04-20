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
        end
      end
    end
  end
end
