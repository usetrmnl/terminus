# frozen_string_literal: true

module Terminus
  module Repositories
    # The model repository.
    class Model < DB::Repository[:model]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        with_associations.order { label.asc }
                         .to_a
      end

      def delete_all(**) = model.where(**).delete

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      def find_or_create(name:, **)
        model.dataset.insert_conflict(target: :name, conflict_action: :nothing).insert(name:, **)
        find_by name:
      end

      def search key, value
        with_associations.where(Sequel.ilike(key, "%#{value}%"))
                         .order { created_at.asc }
                         .to_a
      end

      def where(**)
        with_associations.where(**)
                         .order { created_at.asc }
                         .to_a
      end

      private

      def with_associations = model.combine(:default_palette)
    end
  end
end
