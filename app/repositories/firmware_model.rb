# frozen_string_literal: true

module Terminus
  module Repositories
    # The firmware model repository.
    class FirmwareModel < DB::Repository[:firmware_model]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        firmware_model.order { created_at.asc }
                      .to_a
      end

      def find(id) = (firmware_model.by_pk(id).one if id)

      def find_by(**) = firmware_model.where(**).one

      def where(**)
        firmware_model.where(**)
                      .order { created_at.asc }
                      .to_a
      end
    end
  end
end
