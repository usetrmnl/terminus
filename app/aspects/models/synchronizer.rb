# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Models
      # A models synchronizer with Core server.
      class Synchronizer
        include Deps[
          :trmnl_api,
          model_repository: "repositories.model",
          palette_repository: "repositories.palette",
          join_repository: "repositories.model_palette"
        ]

        include Initable[kinds: %w[byod kindle tidbyt trmnl]]
        include Dry::Monads[:result]

        def call
          result = trmnl_api.models

          case result
            in Success(*payload)
              delete payload.map(&:name)
              payload.each { |item| process item, palette_repository.all }
            else result
          end
        end

        private

        def delete remote_names
          locals = model_repository.where kind: kinds
          local_names = locals.map(&:name)

          model_repository.delete_all kind: kinds, name: local_names - remote_names
        end

        def process item, palettes
          attributes = item.to_h
          names = attributes[:palette_names]
          model = upsert item, attributes

          add_missing_palettes names, palettes, model
          set_default_palette model, names
        end

        def upsert item, attributes
          record = model_repository.find_by name: item.name

          if record
            model_repository.update(record.id, **attributes)
          else
            model_repository.create(**attributes)
          end
        end

        # :reek:TooManyStatements
        def add_missing_palettes names, all, model
          model_id = model.id
          required_ids = all.select { names.include? it.name }
                            .map(&:id)
          existing_ids = join_repository.where(model_id:).map(&:palette_id)

          (required_ids - existing_ids).each do |palette_id|
            join_repository.create model_id:, palette_id:
          end

          model
        end

        def set_default_palette model, names
          return if model.default_palette_id

          palette = palette_repository.find_by name: names.last

          return unless palette

          model_repository.update model.id, default_palette_id: palette.id
        end
      end
    end
  end
end
