# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "yaml"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Local
          # Creates extension from zip file export.
          class Creator
            include Deps[
              "aspects.unzipper",
              "aspects.errors.detailer",
              extension_creator: "aspects.extensions.importers.local.creators.extension",
              exchange_creator: "aspects.extensions.importers.local.creators.exchange"
            ]
            include Initable[
              key_map: {
                "configuration.yml" => :configuration,
                "template.html.liquid" => :template
              }
            ]
            include Dry::Monads[:result]

            def initialize(schema: Schemas::Import, **)
              @schema = schema
              super(**)
            end

            def call io, attributes: {}
              unzipper.call(io)
                      .fmap { |entries| transform entries }
                      .fmap { attributes.replace it }
                      .bind { schema.call(it).to_monad }
                      .alt_map { detailer.call it, "Import " }
                      .bind { extension_creator.call attributes }
                      .bind { create_exchanges it, attributes }
            end

            private

            attr_reader :schema

            def transform entries
              entries.transform_keys!(key_map).then do |adaptations|
                {**adaptations, **YAML.load(adaptations.fetch(:configuration, Core::EMPTY_STRING))}
              end
            end

            def create_exchanges extension, attributes
              attributes.fetch("exchanges", Core::EMPTY_ARRAY)
                        .reduce(Success(extension)) { |result, item| create_exchange result, item }
            end

            def create_exchange result, attributes
              result.bind do |extension|
                exchange_creator.call(attributes.merge!(extension_id: extension.id))
                                .fmap { extension }
              end
            end
          end
        end
      end
    end
  end
end
