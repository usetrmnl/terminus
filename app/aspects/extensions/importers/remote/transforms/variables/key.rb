# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transforms
            module Variables
              # A Liquid template variable key transformer.
              class Key
                include Initable[
                  key_map: {
                    /\Adata/ => "source_1",
                    /\Atrmnl\.plugin_settings\.instance_name/ => "extension.label",
                    /\Atrmnl\.plugin_settings\.custom_fields_values/ => "extension.values",
                    /\Atrmnl\.plugin_settings\.custom_fields\[0\]/ => "extension.fields[0]",
                    /\A(?<key>[a-z0-9_]+)/i => "source_1."
                  },
                  parser: Regexp
                ]

                def call content
                  key_map.each do |pattern, modification|
                    content.sub! pattern do
                      last_match = parser.last_match

                      return modification if last_match.size == 1

                      key = last_match[:key]

                      return content if key.start_with? "source_1"

                      "#{modification}#{key}"
                    end
                  end

                  content
                end
              end
            end
          end
        end
      end
    end
  end
end
