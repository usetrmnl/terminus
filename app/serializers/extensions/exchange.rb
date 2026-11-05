# auto_register: false
# frozen_string_literal: true

require "initable"

module Terminus
  module Serializers
    module Extensions
      # An extension serializer for specific keys.
      class Exchange
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

        include Initable[keys: KEYS]

        def initialize(record, transformer: Terminus::Serializers::Transformers::Time, **)
          @record = record
          @transformer = transformer
          super(**)
        end

        def to_h
          attributes = record.to_h.slice(*keys)
          attributes.transform_values!(&transformer)
          attributes
        end

        private

        attr_reader :record, :transformer
      end
    end
  end
end
