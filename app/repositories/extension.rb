# frozen_string_literal: true

module Terminus
  module Repositories
    # The extension repository.
    class Extension < DB::Repository[:extension]
      include Deps[ha_config_repository: "repositories.extension_home_assistant_config"]

      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        extension.order { created_at.asc }
                 .to_a
      end

      def create_with_devices attributes, device_ids
        transaction do
          record = create attributes

          create_associations :extension_device, record, :device_id, device_ids
          record
        end
      end

      def create_with_models attributes, model_ids
        transaction do
          record = create attributes

          create_associations :extension_model, record, :model_id, model_ids
          record
        end
      end

      def create_with_home_assistant attributes, home_assistant_attributes
        transaction do
          record = create attributes
          ha_config_repository.upsert_by_extension_id extension_id: record.id,
                                                      **home_assistant_attributes
          record
        end
      end

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      def search key, value
        extension.where(Sequel.ilike(key, "%#{value}%"))
                 .order { created_at.asc }
                 .to_a
      end

      def update_with_devices id, attributes, device_ids
        transaction do
          record = update id, attributes

          update_associations :extension_device, id, :device_id, device_ids
          record
        end
      end

      def update_with_models id, attributes, model_ids
        transaction do
          record = update id, attributes

          update_associations :extension_model, id, :model_id, model_ids
          record
        end
      end

      def update_with_home_assistant id, attributes, home_assistant_attributes
        transaction do
          record = update id, attributes
          ha_config_repository.upsert_by_extension_id extension_id: id, **home_assistant_attributes
          record
        end
      end

      def where(**)
        extension.where(**)
                 .order { created_at.asc }
                 .to_a
      end

      private

      def with_associations = extension.combine :devices, :models, :extension_home_assistant_config

      # rubocop:todo Metrics/ParameterLists
      def create_associations name, record, foreign_key, values
        associations = values.map { |id| {extension_id: record.id, foreign_key => id} }
        __send__(name).changeset(:create, associations).commit
      end
      # rubocop:enable Metrics/ParameterLists

      # :reek:FeatureEnvy
      # :reek:TooManyStatements
      # rubocop:todo Metrics/ParameterLists
      def update_associations name, id, foreign_key, values
        association = __send__ name

        association.where(extension_id: id).exclude(foreign_key => values).delete

        old_ids = association.where(extension_id: id, foreign_key => values).map(foreign_key)
        new_ids = values.reject { |id| old_ids.include? id.to_i }
        associations = new_ids.map { |model_id| {extension_id: id, foreign_key => model_id} }

        association.changeset(:create, associations).commit
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
