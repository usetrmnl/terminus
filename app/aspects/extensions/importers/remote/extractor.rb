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
            include Deps["aspects.downloader", "aspects.unzipper"]
            include Initable[uri: "https://usetrmnl.com/api/plugin_settings/%<id>s/archive"]
            include Dry::Monads[:result]

            using Refinements::Pathname

            def call id
              format(uri, id:).then { downloader.call it }
                              .bind { |response| unzipper.call response.body.to_s }
                              .fmap { |attributes| symbolize_keys attributes }
            end

            private

            def symbolize_keys attributes
              attributes.transform_keys! { Pathname(it).name.to_s.to_sym }
            end
          end
        end
      end
    end
  end
end
