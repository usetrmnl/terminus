# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transforms
            # A specialized dependency container resolver for Liquid template transforms.
            class Resolver
              include Initable[
                categories: {
                  tags: %w[
                    aspects.extensions.importers.remote.transforms.tags.render
                  ],
                  variables: %w[
                    aspects.extensions.importers.remote.transforms.variables.index
                    aspects.extensions.importers.remote.transforms.variables.key
                  ]
                }
              ]

              def call key, container: Hanami.app.container
                categories.fetch(key).map { container[it] }
              end
            end
          end
        end
      end
    end
  end
end
