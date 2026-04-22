# frozen_string_literal: true

module Terminus
  module Repositories
    # The palette repository.
    class Palette < DB::Repository[:palette]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        palette.order { label.asc }
               .to_a
      end

      def delete_all(**) = palette.where(**).delete

      def find(id) = (palette.by_pk(id).one if id)

      def find_by(**) = palette.where(**).one

      def search key, value
        palette.where(Sequel.ilike(key, "%#{value}%"))
               .order { label.asc }
               .to_a
      end

      def where(**)
        palette.where(**)
               .order { label.asc }
               .to_a
      end
    end
  end
end
