# auto_register: false
# frozen_string_literal: true

require "core"
require "initable"

module Terminus
  module Serializers
    # A playlist serializer for specific keys.
    class Playlist
      include Initable[
        keys: %i[id name label current_item_id mode created_at updated_at],
        item_serializer: PlaylistItem
      ]

      def initialize(record, transformer: Transformers::Time, **)
        super(**)
        @record = record
        @keys = keys
        @transformer = transformer
      end

      def to_h
        return Core::EMPTY_HASH unless record

        attributes = record.to_h.slice(*keys)
        attributes.transform_values!(&transformer)
        attributes[:items] = items
        attributes
      end

      private

      attr_reader :record, :keys, :transformer

      def items
        record.playlist_items.map { item_serializer.new(it).to_h }
      rescue NoMethodError, ROM::Struct::MissingAttribute
        Core::EMPTY_ARRAY
      end
    end
  end
end
