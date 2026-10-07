# frozen_string_literal: true

module Terminus
  module Repositories
    # The screen repository.
    class Screen < DB::Repository[:screen]
      commands :create

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        with_associations.order { updated_at.desc }
                         .to_a
      end

      def create_with_image path, mold, struct
        path.open { |io| struct.upload io, metadata: {"filename" => mold.file_name} }
        find create(image_data: struct.image_attributes, **mold.image_attributes).id
      end

      def delete id
        find(id).then { it.image_destroy if it }
        screen.by_pk(id).delete
      end

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      def search key, value
        with_associations.where(Sequel.ilike(key, "%#{value}%"))
                         .order { created_at.asc }
                         .to_a
      end

      def upsert_with_image path, mold, struct
        record = find_by(name: mold.name, model_id: mold.model_id).then do |found|
          found ? update_with_image(path, mold, found) : create_with_image(path, mold, struct)
        end

        find record.id
      end

      def where(**)
        with_associations.where(**)
                         .order { created_at.asc }
                         .to_a
      end

      private

      def with_associations = screen.combine :model, :template, :extension

      def update_with_image path, mold, record
        path.open { |io| record.replace io, metadata: {"filename" => mold.file_name} }
        update record.id, image_data: record.image_attributes, **mold.image_attributes
      end
    end
  end
end
