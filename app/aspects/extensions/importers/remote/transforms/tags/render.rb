# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transforms
            module Tags
              # A Liquid template variable index transformer.
              class Render
                include Initable[
                  name: "render",
                  pattern: /
                    (?<key>[0=9a-zA-Z_]+)    # Alphanumeric key.
                    :\s                      # Colon with space delimiter.
                    (?<value>[0=9a-zA-Z_]+)  # Alphanumeric value.
                  /x,
                  key_map: {"trmnl" => "extension", "rss" => "source_1"}.freeze,
                  value_map: {"trmnl" => "extension", "rss" => "source_1.rss"}.freeze,
                  parser: Regexp
                ]

                def call content
                  return content unless content.start_with? name

                  content.gsub! pattern do
                    key, value = parser.last_match.named_captures.values_at "key", "value"
                    "#{key_map.fetch key, key}: #{value_map.fetch value, value}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
