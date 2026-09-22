# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Local
          module Creators
            # Creates extension.
            class Extension
              include Deps[
                "aspects.errors.detailer",
                :i18n,
                :logger,
                "aspects.jobs.schedule",
                repository: "repositories.extension"
              ]
              include Dry::Monads[:result]

              def initialize(schema: Schemas::Extension, problem: Aspects::Errors::Problem, **)
                @schema = schema
                @problem = problem
                super(**)
              end

              def call attributes
                schema.call(attributes)
                      .to_monad
                      .alt_map { detailer.call it, "Extension " }
                      .fmap { create it.to_h }
              rescue ROM::SQL::UniqueConstraintError => error
                Failure problem.duplicate(error.message, nil).detail
              end

              private

              attr_reader :schema, :problem

              def create attributes
                repository.create(attributes).tap do |extension|
                  log extension
                  schedule.upsert(*extension.to_schedule)
                end
              end

              def log extension
                logger.debug do
                  message = i18n.translate(
                    "aspects.extensions.importers.local.creators.extension.imported"
                  )

                  {tags: [{extension_id: extension.id}], message:}
                end
              end
            end
          end
        end
      end
    end
  end
end
