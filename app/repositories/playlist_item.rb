# frozen_string_literal: true

module Terminus
  module Repositories
    # The playlist repository.
    class PlaylistItem < DB::Repository[:playlist_item]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        with_associations.order { [playlist_id, position.asc] }
                         .to_a
      end

      def create_with_position(offset: 1, **)
        playlist_item.transaction do
          playlist_item.command(:create)
                       .call(position: playlist_item.count + offset, **)
                       .then { find it.id }
        end
      end

      def delete_all(**) = playlist_item.where(**).delete

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      def next_item(playlist_id:, after:) = playlist_item.next_item(playlist_id:, after:)

      def where(**)
        with_associations.where(**)
                         .order { [playlist_id, position.asc] }
                         .to_a
      end

      private

      def with_associations = playlist_item.combine :playlist, :screen
    end
  end
end
