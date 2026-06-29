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
                  # Order matters.
                  key_map: {
                    /\Adata\z/ => "source_1",
                    "trmnl.plugin_settings.instance_name" => "extension.label",
                    "trmnl.plugin_settings.custom_fields_values" => "extension.values",
                    "trmnl.plugin_settings.custom_fields[0]" => "extension.fields[0]",
                    /\A(?<key>rss.+)\z/i => "source_1."
                  },
                  key_skip: /source_\d+/,
                  parser: Regexp
                ]

                # :reek:TooManyStatements
                def call content
                  key_map.each do |pattern, modification|
                    content.sub! pattern do
                      last_match = parser.last_match

                      next modification if last_match.size == 1

                      rekey last_match[:key], modification
                    end
                  end

                  content
                end

                private

                def rekey(key, prefix) = key.start_with?(key_skip) ? key : "#{prefix}#{key}"
              end
            end
          end
        end
      end
    end
  end
end
