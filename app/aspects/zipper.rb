# frozen_string_literal: true

require "dry/monads"
require "refinements/string"

module Terminus
  module Aspects
    # A monadic compressor of zip file content.
    class Zipper
      include Deps["zip.output_stream"]
      include Dry::Monads[:result]

      using Refinements::String

      def self.compress manifest, buffer
        manifest.each do |name, content|
          buffer.put_next_entry name
          buffer.write content
        end
      end

      def call manifest
        output_stream.write_buffer { self.class.compress manifest, it }
                     .tap(&:rewind)
                     .then { Success it }
      rescue TypeError, Zip::Error => error
        Failure error.message.up
      end
    end
  end
end
