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
            # Transforms URI.
            class URIs
              include Initable[
                key: :uris,
                line_pattern: /\r\n|\n|\r|\s/,
                unsupported_pattern: /\{\{.+\}\}/m
              ]

              include Dry::Monads[:result]

              using Refinements::Hash

              def call attributes
                value = String attributes[key]

                if value.match? unsupported_pattern
                  Failure "URLs with Liquid syntax isn't supported at the moment."
                else
                  Success attributes.transform_value!(key) { value.split line_pattern }
                end
              end
            end
          end
        end
      end
    end
  end
end
