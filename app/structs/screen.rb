# frozen_string_literal: true

require "core"
require "refinements/hash"

module Terminus
  module Structs
    # The screen struct.
    class Screen < DB::Struct
      include Terminus::Uploaders::Image::Attachment[:image]

      using Refinements::Hash

      attr_reader :image_data

      def initialize(*, store: Hanami.app[:shrine].storages[:store])
        super(*)
        @store = store
        @attacher = image_attacher
      end

      def bit_depth = image_attributes.dig :metadata, :bit_depth

      def height = image_attributes.dig :metadata, :height

      def image_attributes
        attributes.fetch_value(:image_data, Core::EMPTY_HASH).deep_symbolize_keys
      end

      def image_destroy
        store.delete image_id if image_id
        attributes[:image_data].clear
      end

      def image_id = image_attributes[:id]

      def image_name = image_attributes.dig :metadata, :filename

      def image_name_with_timestamp
        path = Pathname(image_attributes.dig(:metadata, :filename))
        path.sub_ext("-#{updated_at.to_i}").to_s
      end

      def image_open(**)
        io = store.open(image_id, **)
        yield io if block_given?
      ensure
        io.close
      end

      def image_size = image_attributes.dig :metadata, :size

      def image_uri(**) = (store.url(image_id, **) if image_id)

      def attach(io, **)
        attacher.assign(io, **).tap { |file| attributes[:image_data] = file.data }
        self
      end

      def mime_type = image_attributes.dig :metadata, :mime_type

      def replace(io, **)
        store_id = image_id
        attacher.assign(io, **)

        return self unless valid?

        cache_id = attacher.file.id
        attacher.promote_cached.tap { attributes[:image_data] = it.data }
        Jobs::Attachments::CacheDelete.perform_async cache_id
        Jobs::Attachments::StoreDelete.perform_in 60, store_id
        self
      end

      def upload(io, **)
        attacher.upload(io, **).tap { |file| attributes[:image_data] = file.data }
        self
      end

      def errors = attacher.errors

      def valid? = errors.empty?

      def width = image_attributes.dig :metadata, :width

      def popover_attributes = {id:, label:, uri: image_uri, width:, height:}

      private

      attr_reader :store, :attacher, :job
    end
  end
end
