# auto_register: false
# frozen_string_literal: true

require "functionable"
require "refinements/array"
require "refinements/hash"
require "rfc/api/problem"

module Terminus
  module Aspects
    module Errors
      # Builds details for global problems.
      module Problem
        extend Functionable

        using Refinements::Array
        using Refinements::Hash

        def duplicate message, instance
          key, value = message.match(/Key \((?<key>[^)]+)\)=\((?<value>[^)]+)\)/m)
                              .named_captures
                              .values_at "key", "value"

          RFC::API::Problem[
            type: "/problem_details#duplicate_value",
            status: :conflict,
            detail: "#{key.capitalize} must be unique. " \
                    "Please use a value other than #{value.inspect}.",
            instance:
          ]
        end

        def enum message, instance
          key, value = message.match(/"(?<value>.+?)".+:(?<key>.+?)\s/)
                              .named_captures
                              .values_at "key", "value"
          allowed = JSON(message[/\[".+?"\]/m]).to_usage :or

          RFC::API::Problem[
            type: "/problem_details#invalid_enum",
            status: :unprocessable_content,
            detail: "Invalid value for #{key}: #{value.inspect}. Use: #{allowed}.",
            instance:
          ]
        end

        def foreign_key message, instance
          key, value = message.match(/Key \((?<key>[^)]+)\)=\((?<value>[^)]+)\)/m)
                              .named_captures
                              .values_at "key", "value"

          RFC::API::Problem[
            type: "/problem_details#invalid_foreign_key",
            status: :unprocessable_content,
            detail: "Invalid `#{key}` value: #{value}. Does not exist.",
            instance:
          ]
        end

        def out_of_range message, instance
          detail = message.delete_prefix("PG::NumericValueOutOfRange: ERROR:  ").capitalize

          RFC::API::Problem[
            type: "/problem_details#invalid_numeric",
            status: :unprocessable_content,
            detail: "#{detail}. Use a smaller value.",
            instance:
          ]
        end
      end
    end
  end
end
