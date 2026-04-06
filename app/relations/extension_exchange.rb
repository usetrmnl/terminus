# frozen_string_literal: true

module Terminus
  module Relations
    # The extension exchange relation.
    class ExtensionExchange < DB::Relation
      schema :extension_exchange, infer: true do
        associations { belongs_to :extension, relation: :extension }
      end
    end
  end
end
