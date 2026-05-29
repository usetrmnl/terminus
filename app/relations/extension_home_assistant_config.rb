# frozen_string_literal: true

module Terminus
  module Relations
    # The extension home assistant config relation.
    class ExtensionHomeAssistantConfig < DB::Relation
      schema :extension_home_assistant_config, infer: true do
        associations { belongs_to :extension, relation: :extension }
      end
    end
  end
end
