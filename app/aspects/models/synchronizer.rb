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
          default_palette_name = attributes.delete :default_palette_name
          model = upsert item, attributes

          add_missing_palettes attributes[:palette_names], palettes, model
          set_default_palette model, default_palette_name
        end

        def upsert item, attributes
          record = model_repository.find_by name: item.name

          if record
            model_repository.update(record.id, **attributes)
          else
            model_repository.create(**attributes)
          end
        end

        def add_missing_palettes names, all, model
          required_ids = all.select { names.include? it.name }
                            .map(&:id)

          (required_ids - existing_palette_ids(model)).each do |palette_id|
            join_repository.create model_id: model.id, palette_id:
          end

          model
        end

        def existing_palette_ids model
          join_repository.where(model_id: model.id).map(&:palette_id)
        end

        def set_default_palette model, name
          return if model.default_palette_id

          palette_repository.find_by(name:).then do |palette|
            model_repository.update model.id, default_palette_id: palette.id if palette
          end
        end
      end
    end
  end
end
