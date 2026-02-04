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

              KINDS = {"polling" => "poll", "static" => "static", "webhook" => "webhook"}.freeze

              def initialize kinds: KINDS
                @kinds = kinds
                @keys = kinds.keys
              end

              # :reek:TooManyStatements
              def call attributes
                strategy = attributes.delete :strategy
                static_data = attributes.delete :static_data
                kind = kinds[strategy]
                body = kind == "static" ? static_data : attributes[:body]

                if keys.include? strategy
                  Success attributes.merge!(kind:, body:)
                else
                  Failure "Unsupported kind: #{strategy}. Use: #{keys.to_sentence :or}."
                end
              end

              private

              attr_reader :kinds, :keys
            end
          end
        end
      end
    end
  end
end
