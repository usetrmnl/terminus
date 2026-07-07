# frozen_string_literal: true

require "dry/monads"
require "refinements/array"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms (mutates) strategy and polling/static attributes for initialization.
            class Kind
              include Dry::Monads[:result]

              using Refinements::Array

              KINDS = {"polling" => "poll", "static" => "static"}.freeze

              def initialize kinds: KINDS
                @kinds = kinds
                @keys = kinds.keys
              end

              def call attributes
                strategy = attributes.delete :strategy
                usage = "Use: #{keys.to_sentence :or}"

                if keys.include? strategy
                  Success process(strategy, attributes)
                elsif attributes[:oauth_enabled]
                  Failure "Unsupported kind: oauth. #{usage}."
                else
                  Failure "Unsupported kind: #{strategy}. #{usage}."
                end
              end

              private

              attr_reader :kinds, :keys

              def process strategy, attributes
                kind = kinds[strategy]
                static_body = attributes.delete :static_data

                if kind == "static"
                  attributes.merge! kind:, static_body:
                else
                  attributes.merge! kind:, poll_body: attributes[:poll_body]
                end
              end
            end
          end
        end
      end
    end
  end
end
