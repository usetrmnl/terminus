# frozen_string_literal: true

require "dry/core"
require "hanami/view"
require "initable"
require "refinements/string"

module Terminus
  module Views
    module Parts
      # The extension exchange presenter.
      class Exchange < Hanami::View::Part
        include Deps["aspects.extensions.curler", "aspects.extensions.uri_builder"]
        include Initable[json_formatter: Aspects::JSONFormatter]

        using Refinements::String

        def curl(data = Dry::Core::EMPTY_HASH) = curler.call value, data

        def formatted_body = json_formatter.call body

        def formatted_data = json_formatter.call data

        def formatted_errors = json_formatter.call errors

        def formatted_headers = json_formatter.call headers

        def formatted_verb = verb.upcase

        def requests data = Dry::Core::EMPTY_HASH, length = 50
          uri_builder.call(template, data).map { it.trim_end length }
        end
      end
    end
  end
end
