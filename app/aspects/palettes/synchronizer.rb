# frozen_string_literal: true

require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Palettes
      # A palettes synchronizer with Core server.
      class Synchronizer
        include Deps[:trmnl_api, repository: "repositories.palette"]
        include Initable[default_kind: "trmnl"]
        include Dry::Monads[:result]

        using Refinements::Hash

        def call
          result = trmnl_api.palettes

          case result
            in Success(*payload)
              delete payload.map(&:name)
              process payload
            else result
          end
        end

        private

        def delete remote_names
          locals = repository.where kind: default_kind
          local_names = locals.map(&:name)

          repository.delete_all kind: default_kind, name: local_names - remote_names
        end

        def process payload
          payload.each { |item| upsert item }
          Success()
        end

        def upsert item
          attributes = transform item
          record = repository.find_by name: item.name

          if record
            repository.update(record.id, **attributes)
          else
            repository.create(**attributes)
          end
        end

        def transform(item) = item.to_h.then { {**it, kind: default_kind} }
      end
    end
  end
end
