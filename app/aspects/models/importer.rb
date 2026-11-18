# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "pipeable"
require "yaml"

module Terminus
  module Aspects
    module Models
      # Imports (creates) model from zip file.
      class Importer
        include Deps[
          "aspects.unzipper",
          "aspects.errors.detailer",
          :i18n,
          :logger,
          repository: "repositories.model",
          palette_repository: "repositories.palette"
        ]
        include Initable[
          key_map: {"configuration.yml" => :configuration},
          problem: Aspects::Errors::Problem
        ]
        include Dry::Monads[:result]
        include Pipeable

        def initialize(schema: Schemas::Models::Import, **)
          @schema = schema
          super(**)
        end

        def call io
          process io
        rescue ROM::SQL::UniqueConstraintError => error
          Failure problem.duplicate(error.message, nil).detail
        end

        private

        attr_reader :schema

        def process io
          pipe(
            unzipper.call(io),
            fmap { |entries| transform entries },
            validate(schema),
            amap { detailer.call it, "Import " },
            fmap { create it.to_h }
          )
        end

        def transform entries
          entries.transform_keys!(key_map).then { {**it, **YAML.load(it[:configuration])} }
        end

        def create attributes
          default_palette_id = find_palette_id attributes.delete(:default_palette_name)
          repository.create(attributes.merge!(default_palette_id:)).tap { log it }
        end

        def find_palette_id(name) = palette_repository.find_by(name:).then { it.id if it }

        def log model
          logger.debug do
            {
              tags: [{model_id: model.id}],
              message: i18n.translate("aspects.models.importer.imported")
            }
          end
        end
      end
    end
  end
end
