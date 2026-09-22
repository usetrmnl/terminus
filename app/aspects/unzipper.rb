# frozen_string_literal: true

require "dry/monads"
require "initable"
require "refinements/string"

module Terminus
  module Aspects
    # A monadic decompressor of zip file content.
    class Unzipper
      include Deps[:i18n, "zip.file"]
      include Initable[max_files: 10, max_file_size: 1024**2]
      include Dry::Monads[:result]

      using Refinements::String

      def call io
        file.open_buffer(io) { break decompress it }
      rescue TypeError, Zip::Error => error
        Failure error.message.up
      end

      private

      def decompress manifest
        return max_files_failure manifest if manifest.size > max_files

        manifest.each.reduce Success({}) do |result, entry|
          check_max_file_size(result, entry).bind { read entry, it }
        end
      end

      def max_files_failure manifest
        Failure "File limit exceeded: #{manifest.size} (actual), #{max_files} (maximum)."
      end

      def read entry, attributes
        input = entry.get_input_stream
        message = i18n.translate "aspects.unzipper.no_directories"

        return Failure message if input == Zip::NullInputStream

        attributes[entry.name] = input.read
        Success attributes
      end

      def check_max_file_size result, entry
        file_size = entry.size

        return result if file_size <= max_file_size

        Failure "File size exceeded (#{entry.name}): " \
                "#{file_size} (actual), #{max_file_size} (maximum)."
      end
    end
  end
end
