# auto_register: false
# frozen_string_literal: true

require "initable"

module Terminus
  module Serializers
    module Extensions
      # An extension serializer for specific keys.
      class Exchange
        include Initable[transformer: proc { Terminus::Serializers::Transformers::Time }]

        KEYS = %i[
          id
          headers
          verb
          template
          body
          data
          errors
          refreshed_at
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
          attributes
        end

        private

        attr_reader :record, :keys
      end
    end
  end
end
