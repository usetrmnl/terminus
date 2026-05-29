# frozen_string_literal: true

module Terminus
  module Structs
    # The home assistant connection struct.
    class HomeAssistantConnection < DB::Struct
      def masked_access_token
        token = String access_token
        return if token.empty?

        ["*" * [token.size - 4, 0].max, token[-4..]].join
      end
    end
  end
end
