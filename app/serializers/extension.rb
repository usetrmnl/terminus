# auto_register: false
# frozen_string_literal: true

module Terminus
  module Serializers
    # An extension serializer for specific keys.
    class Extension
      KEYS = %i[
        id
        label
        name
        description
        kind
        mode
        tags
        static_body
        fields
        template
        data
        interval
        unit
        days
        last_day_of_month
        start_at
        created_at
        updated_at
      ].freeze

      def initialize record, keys: KEYS, transformer: Transformers::Time
        @record = record
        @keys = keys
        @transformer = transformer
      end

      def to_h
        attributes = record.to_h.slice(*keys)
        attributes.transform_values!(&transformer)
        attributes
      end

      private

      attr_reader :record, :keys, :transformer
    end
  end
end
