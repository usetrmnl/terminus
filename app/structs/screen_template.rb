# frozen_string_literal: true

module Terminus
  module Structs
    # The screen template struct.
    class ScreenTemplate < DB::Struct
      def screen_attributes = {template_id: id, name:, label:, content:}
    end
  end
end
