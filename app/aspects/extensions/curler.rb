# frozen_string_literal: true

require "core"
require "initable"

module Terminus
  module Aspects
    module Extensions
      # Renders curl command for exchange and associated data.
      class Curler
        include Deps["aspects.extensions.uri_builder"]
        include Initable[json_formatter: proc { Terminus::Aspects::JSONFormatter }]

        def self.render_request verb, uri
          verb.include?("get") ? "curl #{uri}" : "curl --request #{verb.upcase} #{uri}"
        end

        def self.render_headers attributes
          return if Hash(attributes).empty?

          attributes.map { |key, value| "--header '#{key.downcase}: #{value}'" }
        end

        def call extension, exchange
          uri_builder.call(extension, exchange.template)
                     .map { |uri| render uri, exchange }
                     .join "\n"
        end

        private

        def render uri, exchange
          klass = self.class

          [
            klass.render_request(exchange.verb, uri),
            *klass.render_headers(exchange.headers),
            render_body(exchange.body)
          ].compact
           .each
           .with_index
           .map { |line, index| index.zero? ? line : "     #{line}" }
           .join " \\\n"
        end

        def render_body attributes
          return if Hash(attributes).empty?

          "--data $'#{json_formatter.call attributes}'"
        end
      end
    end
  end
end
