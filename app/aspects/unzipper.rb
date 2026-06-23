# frozen_string_literal: true

require "dry/monads"
require "refinements/string"

module Terminus
  module Aspects
    # A monadic decompressor of zip file content.
    class Unzipper
      include Deps["zip.file"]
      include Dry::Monads[:result]

      using Refinements::String

      def self.decompress manifest
        manifest.each.with_object({}) do |entry, attributes|
          attributes[entry.name] = entry.get_input_stream.read
        end
      end

      def call io
        file.open_buffer(io) { break self.class.decompress it }
            .then { |attributes| Success attributes }
      rescue TypeError, Zip::Error => error
        Failure error.message.up
      end
    end
  end
end
