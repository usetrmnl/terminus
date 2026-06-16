# frozen_string_literal: true

module Terminus
  module Relations
    # The screen template relation.
    class ScreenTemplate < DB::Relation
      schema :screen_template, infer: true do
        associations { has_many :screens, relation: :screen, as: :screens }
      end
    end
  end
end
