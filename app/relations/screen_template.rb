# frozen_string_literal: true

module Terminus
  module Relations
    # The screen template relation.
    class ScreenTemplate < DB::Relation
      schema :screen_templates, infer: true do
        associations { belongs_to :device }
      end
    end
  end
end
