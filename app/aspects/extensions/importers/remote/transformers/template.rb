# frozen_string_literal: true

require "dry/monads"
require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms (mutates) the full Liquid template for initialization.
            class Template
              include Initable[
                key_map: {
                  "rss." => "source.rss.",
                  "source_1.data" => "source_1",
                  "trmnl.plugin_settings.custom_fields_values" => "extension.values",
                  "trmnl.plugin_settings.custom_fields[0]" => "extension.fields[0]"
                },
                pattern: /
                  (?<prefix>IDX)  # Prefix
                  _               # Delimiter
                  (?<index>\d+)   # Index
                /mx,
                layout: <<~BODY
                  <div class="{{extension.css_classes}}">
                    <div class="view view--full">
                      %<content>s
                    </div>
                  </div>
                BODY
              ]

              include Dry::Monads[:result]

              using Refinements::Hash

              def call attributes, archive
                content = merge_content archive

                format_uris content
                format_fields content

                Success attributes.merge!(template: content)
              end

              private

              def merge_content archive
                archive.use do |shared, full|
                  content = format layout, content: full
                  [shared, content].compact.join "\n\n"
                end
              end

              def format_uris content, offset: 1
                content.gsub! pattern do
                  captures = Regexp.last_match.named_captures
                  "source_#{captures["index"].to_i + offset}"
                end
              end

              def format_fields content
                key_map.each { |trmnl, terminus| content.gsub! trmnl, terminus }
              end
            end
          end
        end
      end
    end
  end
end
