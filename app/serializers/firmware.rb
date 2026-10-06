# auto_register: false
# frozen_string_literal: true

module Terminus
  module Serializers
    # A model serializer for specific keys.
    class Firmware
      KEYS = %i[id version created_at updated_at].freeze

      def initialize record, keys: KEYS, transformer: Transformers::Time
        @record = record
        @keys = keys
        @transformer = transformer
      end

      def to_h
        attributes = record.to_h.slice(*keys).merge(file_name: "#{record.version}.bin")
        attributes.transform_values!(&transformer)
        attributes.merge! metadata, uri: record.attachment_uri if record.attachment_id
        attributes
      end

      private

      attr_reader :record, :keys, :transformer

      def metadata = record.attachment_attributes[:metadata].slice :mime_type, :size
    end
  end
end
