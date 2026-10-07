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

      def all = firmware.by_version_desc.to_a

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

      def find(id) = (firmware.by_pk(id).one if id)

      def find_by(**) = firmware.where(**).one

      def latest = all.first

      def search key, value
        firmware.where(Sequel.like(key, "%#{value}%"))
                .order { created_at.asc }
                .to_a
      end

      def where_with_model(**) = firmware.with_model_join(**)
    end
  end
end
