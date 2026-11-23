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

        def duplicate message, instance, finesse: Finesse
          RFC::API::Problem[
            type: "/problem_details#duplicate_value",
            status: :conflict,
            detail: finesse.public_send(__method__, message),
            instance:
          ]
        end

        def enum message, instance, finesse: Finesse
          RFC::API::Problem[
            type: "/problem_details#invalid_enum",
            status: :unprocessable_content,
            detail: finesse.public_send(__method__, message),
            instance:
          ]
        end

        def foreign_key message, instance, finesse: Finesse
          RFC::API::Problem[
            type: "/problem_details#invalid_foreign_key",
            status: :unprocessable_content,
            detail: finesse.public_send(__method__, message),
            instance:
          ]
        end

        def out_of_range message, instance, finesse: Finesse
          RFC::API::Problem[
            type: "/problem_details#invalid_numeric",
            status: :unprocessable_content,
            detail: finesse.public_send(__method__, message),
            instance:
          ]
        end
      end
    end
  end
end
