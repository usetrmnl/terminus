# frozen_string_literal: true

module Terminus
  module Repositories
    # The extension repository.
    class Extension < DB::Repository[:extension]
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

          extension_device.create_all record.id, device_ids
          record
        end
      end

      def create_with_models attributes, model_ids
        transaction do
          record = create attributes

          extension_model.create_all record.id, model_ids
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

          extension_device.update_all id, device_ids
          record
        end
      end

      def update_with_models id, attributes, model_ids
        transaction do
          record = update id, attributes

          extension_model.update_all id, model_ids
          record
        end
      end

      def where(**)
        extension.where(**)
                 .order { created_at.asc }
                 .to_a
      end

      private

      def with_associations = extension.combine :devices, :models
    end
  end
end
