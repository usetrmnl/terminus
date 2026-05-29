# auto_register: false
# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Schemas
    # Coerces a key's value to true when key is missing.
    module Coercers
      using Refinements::Hash

      DefaultToTrue = lambda do |key, result|
        return unless result.output

        attributes = Hash result.to_h
        attributes[key] = true unless result.key? key

        attributes
      end
    end
  end
end
