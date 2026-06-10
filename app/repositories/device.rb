# frozen_string_literal: true

module Terminus
  module Repositories
    # The device repository.
    class Device < DB::Repository[:device]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        with_associations.order { created_at.asc }
                         .to_a
      end

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      def mirror_playlist ids, playlist_id
        device.where(Sequel.|({id: ids}, {playlist_id:}))
              .update(playlist_id: Sequel.case({{id: ids} => playlist_id}, nil))
      end

      def search key, value
        device.combine(:model)
              .where(Sequel.ilike(key, "%#{value}%"))
              .order { created_at.asc }
              .to_a
      end

      def update_by_mac_address(value, **attributes)
        device = find_by mac_address: value

        return device if attributes.empty?
        return unless device

        update device.id, **attributes
      end

      def where(**)
        with_associations.where(**)
                         .order { created_at.asc }
                         .to_a
      end

      private

      def with_associations = device.combine :model, :playlist
    end
  end
end
