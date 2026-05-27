# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transforms
            module Variables
              # A Liquid template variable index transformer.
              class Index
                include Initable[
                  index_pattern: /
                    (?<prefix>IDX)  # Prefix
                    _               # Delimiter
                    (?<index>\d+)   # Index
                  /x,
                  parser: Regexp
                ]

                def call content, offset: 1
                  content.gsub! index_pattern do
                    captures = parser.last_match.named_captures
                    "source_#{captures["index"].to_i + offset}"
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
