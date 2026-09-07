# auto_register: false
# frozen_string_literal: true

require "initable"

module Terminus
  module Serializers
    # An extension serializer for specific keys.
    class Extension
      include Deps[
        model_repository: "repositories.extension_model",
        device_repository: "repositories.extension_device"
      ]
      include Initable[transformer: proc { Terminus::Serializers::Transformers::Time }]

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

      def initialize(record, keys: KEYS, **)
        @record = record
        @keys = keys
        super(**)
      end

      def to_h
        attributes = record.to_h.slice(*keys)
        attributes.transform_values!(&transformer)
        attributes.merge! model_ids: load_model_ids(record), device_ids: load_device_ids(record)
      end

      private

      attr_reader :record, :keys

      def load_model_ids record
        model_repository.where(extension_id: record.id).map(&:model_id)
      end

      def load_device_ids record
        device_repository.where(extension_id: record.id).map(&:device_id)
      end
    end
  end
end
