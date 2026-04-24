# auto_register: false
# frozen_string_literal: true

require "core"
require "refinements/hash"

module Terminus
  module Schemas
    # Coerces a key's value to an empty array when key is missing.
    module Coercers
      using Refinements::Hash

      DefaultToArray = lambda do |key, result, default = Core::EMPTY_ARRAY|
        attributes = Hash result.to_h
        attributes[key] = default unless result.key? key

        attributes
      end
    end
  end
end
