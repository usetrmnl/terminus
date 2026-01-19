# frozen_string_literal: true

require "dry/monads"
require "initable"
require "refinements/pathname"
require "zip"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          # Downloads and decompresses a TRMNL plugin archive.
          class Extractor
            include Deps["aspects.downloader"]

            include Initable[
              uri: "https://usetrmnl.com/api/plugin_settings/%<id>s/archive",
              client: Zip::File
            ]

            include Dry::Monads[:result]

            using Refinements::Pathname

            def call id
              format(uri, id:).then { downloader.call it }
                              .fmap { |response| extract response }
            rescue Zip::Error => error
              Failure error.message
            end

            private

            # :reek:NestedIterators
            def extract response, content: {}
              client.open_buffer response.body.to_s do |zip|
                zip.each do |entry|
                  key = Pathname(entry.name).name.to_s.to_sym
                  content[key] = entry.get_input_stream.read
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
