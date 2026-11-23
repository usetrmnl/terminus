# auto_register: false
# frozen_string_literal: true

require "functionable"
require "refinements/array"
require "refinements/hash"

module Terminus
  module Aspects
    module Errors
      # Builds details for global problems.
      module Finesse
        extend Functionable

        using Refinements::Array
        using Refinements::Hash

        def duplicate message
          key, value = message.match(/Key \((?<key>[^)]+)\)=\((?<value>[^)]+)\)/m)
                              .named_captures
                              .values_at "key", "value"

          "#{key.capitalize} must be unique. Please use a value other than #{value.inspect}."
        end

        def enum message
          key, value = message.match(/"(?<value>.+?)".+:(?<key>.+?)\s/)
                              .named_captures
                              .values_at "key", "value"
          allowed = JSON(message[/\[".+?"\]/m]).to_usage :or

          "Invalid value for #{key}: #{value.inspect}. Use: #{allowed}."
        end

        def foreign_key message
          key, value = message.match(/Key \((?<key>[^)]+)\)=\((?<value>[^)]+)\)/m)
                              .named_captures
                              .values_at "key", "value"

          "Invalid `#{key}` value: #{value}. Does not exist."
        end

        def out_of_range message
          detail = message.delete_prefix("PG::NumericValueOutOfRange: ERROR:  ").capitalize
          "#{detail}. Use a smaller value."
        end
      end
    end
  end
end
