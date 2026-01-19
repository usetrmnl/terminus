# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          # Transforms remote plugin (recipe) data into extension attributes.
          class Transformer
            include Deps[
              "aspects.extensions.importers.remote.extractor",
              "aspects.extensions.importers.remote.transformers.default",
              "aspects.extensions.importers.remote.transformers.keys",
              "aspects.extensions.importers.remote.transformers.kind",
              "aspects.extensions.importers.remote.transformers.template",
              "aspects.extensions.importers.remote.transformers.poll"
            ]

            include Dry::Monads[:result]

            def initialize(schema: Importers::Remote::Schema, **)
              @schema = schema
              super(**)
            end

            def call(id) = extractor.call(id).bind { |archive| process archive }

            private

            attr_reader :schema

            # :reek:TooManyStatements
            # rubocop:todo Metrics/AbcSize
            def process archive
              # Order matters.
              validate(archive).bind { |attributes| keys.call attributes.to_h }
                               .bind { |attributes| poll.call attributes }
                               .bind { |attributes| kind.call attributes }
                               .bind { |attributes| template.call attributes, archive }
                               .bind { |attributes| default.call attributes }
            end
            # rubocop:enable Metrics/AbcSize

            def validate archive
              YAML.load(archive[:settings])
                  .then { |settings| schema.call settings }
                  .to_monad
            end
          end
        end
      end
    end
  end
end
