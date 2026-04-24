# auto_register: false
# frozen_string_literal: true

require "core"
require "functionable"
require "json"

module Terminus
  module Aspects
    # A simple JSON pretty printer.
    module JSONFormatter
      extend Functionable

      def call data
        case data
          in nil | Core::EMPTY_ARRAY | Core::EMPTY_HASH then Core::EMPTY_STRING
          in Array | Hash then JSON data, indent: "  ", space: " ", object_nl: "\n", array_nl: "\n"
          else fail TypeError, "Unknown type to format as JSON for: #{data.inspect}."
        end
      end
    end
  end
end
