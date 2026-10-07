# frozen_string_literal: true

module Terminus
  module Repositories
    # The firmware repository.
    class Firmware < DB::Repository[:firmware]
      include Deps[:shrine]

      commands :create

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all = with_associations.by_version_desc.to_a

      def create_with_models attributes, model_ids
        transaction do
          record = create attributes

          firmware_model.create_all record.id, model_ids
          record
        end
      end

      def delete id
        find(id).then { it.attachment_destroy if it }
        firmware.by_pk(id).delete
      end

      def delete_all
        firmware.where { attachment_data.has_key "id" }
                .select { attachment_data.get_text("id").as(:attachment_id) }
                .map(:attachment_id)
                .each { shrine.storages[:store].delete it }

        firmware.delete
      end

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      def latest = all.first

      # :reek:FeatureEnvy
      def replace_attachment record, version, io
        return unless io

        record.replace io, metadata: {"filename" => "#{version}.bin"}
        find update(record.id, attachment_data: record.attachment_attributes).id
      end

      def search key, value
        with_associations.where(Sequel.like(key, "%#{value}%"))
                         .order { created_at.asc }
                         .to_a
      end

      def update_with_models id, attributes, model_ids
        transaction do
          record = update id, attributes

          firmware_model.update_all id, model_ids
          record
        end
      end

      def where(**)
        firmware.join(:firmware_model, firmware_id: :id)
                .join(:model, id: firmware_model[:model_id])
                .where(**).to_a
      end

      private

      def with_associations = firmware.combine(:models)
    end
  end
end
