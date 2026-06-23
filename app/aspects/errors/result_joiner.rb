# frozen_string_literal: true

require "refinements/array"
require "refinements/hash"

module Terminus
  module Aspects
    # Joins multiple error messages from a Dry Schema/Validation result into a single sentence.
    module Errors
      using Refinements::Array
      using Refinements::Hash

      ResultJoiner = lambda do |subject, result|
        return result if result.is_a? String

        messages = result.errors.to_h.each.with_object [] do |(key, value), all|
          if value.is_a? Hash
            value.flatten_keys!(delimiter: ".").each do |sub_key, sub_value|
              all.append "#{key}.#{sub_key} #{sub_value.to_sentence}"
            end
          else
            all.append "#{key} #{value.to_sentence}"
          end
        end

        "#{subject} #{messages.to_sentence}."
      end
    end
  end
end
