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
            # Transforms poll URIs/templates.
            class Poll
              include Initable[
                key: :poll_template,
                line_pattern: /\r\n|\n|\r|\s/,
                liquid_pattern: /\{\{.+\}\}/m
              ]

              include Dry::Monads[:result]

              using Refinements::Hash

              def call attributes
                value = String attributes[key]

                if value.match? liquid_pattern
                  attributes[key] = [value]
                  Success attributes
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
