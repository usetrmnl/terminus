# frozen_string_literal: true

module Terminus
  module Relations
    # The home assistant connection relation.
    class HomeAssistantConnection < DB::Relation
      schema :home_assistant_connection, infer: true
    end
  end
end
