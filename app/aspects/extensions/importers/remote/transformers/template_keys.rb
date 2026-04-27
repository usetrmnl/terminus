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
                  "source_1.data" => "source_1",
                  "trmnl.plugin_settings.instance_name" => "extension.label",
                  "trmnl.plugin_settings.custom_fields_values" => "extension.values",
                  "trmnl.plugin_settings.custom_fields[0]" => "extension.fields[0]"
                },
                index_pattern: /
                  (?<prefix>IDX)  # Prefix
                  _               # Delimiter
                  (?<index>\d+)   # Index
                /mx
              ]

              include Dry::Monads[:result]

              def call content
                mutation = content.dup

                format_sources mutation
                format_fields mutation

                Success mutation
              end

              private

              def format_sources content, offset: 1
                content.gsub! index_pattern do
                  captures = Regexp.last_match.named_captures
                  "source_#{captures["index"].to_i + offset}"
                end
              end

              def format_fields content
                key_map.each { |original, modification| content.gsub! original, modification }
              end
            end
          end
        end
      end
    end
  end
end
