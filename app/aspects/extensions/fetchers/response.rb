# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Extensions
      module Fetchers
        # Captures the HTTP response details.
        Response = Data.define :data, :errors do
          def initialize data: {}, errors: {}
            super
          end

          def merge_data(key, attributes = {}) = attributes.merge! key => data

          def merge_errors(key, attributes = {}) = attributes.merge! key => errors
        end
      end
    end
  end
end
