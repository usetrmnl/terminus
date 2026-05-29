# frozen_string_literal: true

module Terminus
  module Structs
    # The extension home assistant config struct.
    class ExtensionHomeAssistantConfig < DB::Struct
      def formatted_attribute_map
        Aspects::JSONFormatter.call attribute_map
      end

      def formatted_entity_ids = Array(entity_ids).join("\n")
    end
  end
end
