# frozen_string_literal: true

module Terminus
  module Repositories
    # The extension exchange repository.
    class ExtensionExchange < DB::Repository[:extension_exchange]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        extension_exchange.order { created_at.asc }
                          .to_a
      end

      def find(id) = (extension_exchange.by_pk(id).one if id)

      def find_by(**) = extension_exchange.where(**).one

      def where(**)
        extension_exchange.where(**)
                          .order { created_at.asc }
                          .to_a
      end
    end
  end
end
