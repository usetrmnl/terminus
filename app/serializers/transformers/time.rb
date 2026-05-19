# auto_register: false
# frozen_string_literal: true

module Terminus
  module Serializers
    module Transformers
      # Transforms SQL time to a string.
      Time = lambda do |value|
        case value
          when Sequel::SQLTime then value.to_s
          when ::Time then value.strftime "%Y-%m-%dT%H:%M:%S%:z"
          else value
        end
      end
    end
  end
end
