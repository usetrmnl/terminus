# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "pipeable"
require "yaml"

module Terminus
  module Aspects
    module Designs
      # Imports (creates) screen template from zip file.
      class Importer
        include Deps[
          "aspects.unzipper",
          "aspects.errors.detailer",
          :i18n,
          :logger,
          repository: "repositories.screen_template"
        ]
        include Initable[
          key_map: {
            "configuration.yml" => :configuration,
            "index.html.liquid" => :content
          },
          problem: Aspects::Errors::Problem
        ]
        include Dry::Monads[:result]
        include Pipeable

        def initialize(schema: Schemas::Designs::Import, **)
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
          repository.create(attributes).tap { |screen_template| log screen_template }
        end

        def log screen_template
          logger.debug do
            {
              tags: [{screen_template_id: screen_template.id}],
              message: i18n.translate("aspects.designs.importer.imported")
            }
          end
        end
      end
    end
  end
end
