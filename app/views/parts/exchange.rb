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
        include Deps["aspects.extensions.uri_builder", renderer: "liquid.default"]
        include Initable[json_formatter: Aspects::JSONFormatter]

        using Refinements::String

        def curl data = Dry::Core::EMPTY_HASH
          uri_builder.call(template, data).map { |uri| curl_request uri }
                                          .join
        end

        def formatted_body = json_formatter.call body

        def formatted_headers = json_formatter.call headers

        def formatted_verb = verb.upcase

        def trimmed_request(length = 20) = "#{formatted_verb} #{template.trim_end length}"

        private

        def curl_request uri
          <<~CONTENT.strip
            curl #{uri} \
            #{curl_headers.join " \\"}
            #{curl_body}
          CONTENT
        end

        def curl_headers
          return Dry::Core::EMPTY_ARRAY if headers.empty?

          headers.map { "--header #{it.downcase}" }
        end

        def curl_body
          return Dry::Core::EMPTY_STRING if body.empty?

          "--data '#{formatted_body}'"
        end
      end
    end
  end
end
