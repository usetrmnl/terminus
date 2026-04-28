# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms a Liquid template to use Terminus keys instead of TRMNL keys.
            class TemplateKeys
              include Initable[
                key_map: {
                  "rss." => "source_1.rss.",
                  "trmnl.plugin_settings.instance_name" => "extension.label",
                  "trmnl.plugin_settings.custom_fields_values" => "extension.values",
                  "trmnl.plugin_settings.custom_fields[0]" => "extension.fields[0]",
                  /(?<prefix>\{\{\s*)(?<key>[a-z0-9_]+)(?<suffix>.*?\}\})/i => "source_1."
                },
                key_skip: "source_",
                index_pattern: /
                  (?<prefix>IDX)  # Prefix
                  _               # Delimiter
                  (?<index>\d+)   # Index
                /mx
              ]

              include Dry::Monads[:result]

              def call content
                mutation = content.dup

                # Order matters.
                reindex mutation
                rekey mutation

                Success mutation
              end

              private

              def reindex content, offset: 1
                content.gsub! index_pattern do
                  captures = Regexp.last_match.named_captures
                  "source_#{captures["index"].to_i + offset}"
                end
              end

              def rekey content
                key_map.each do |original, modification|
                  if original.is_a? String
                    content.gsub! original, modification
                  else
                    rekey_with_regular_expression content, original, modification
                  end
                end
              end

              def rekey_with_regular_expression content, original, modification
                content.gsub! original do
                  prefix, key, suffix = Regexp.last_match.values_at :prefix, :key, :suffix

                  break if key.start_with?(key_skip) || suffix.include?(".")

                  "#{prefix}#{modification}#{key}#{suffix}"
                end
              end
            end
          end
        end
      end
    end
  end
end
