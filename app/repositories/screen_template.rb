# frozen_string_literal: true

module Terminus
  module Repositories
    # The screen template repository.
    class ScreenTemplate < DB::Repository[:screen_template]
      commands :create, update: :by_pk, delete: :by_pk

      def all
        screen_template.order { created_at.desc }
                       .to_a
      end

      def find(id) = (screen_template.by_pk(id).one if id)

      def find_by(**) = screen_template.where(**).one

      def search key, value
        screen_template.where(Sequel.ilike(key, "%#{value}%"))
                       .order { created_at.asc }
                       .to_a
      end

      def where(**)
        screen_template.where(**)
                       .order { created_at.asc }
                       .to_a
      end
    end
  end
end
