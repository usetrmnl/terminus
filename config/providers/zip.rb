# frozen_string_literal: true

Hanami.app.register_provider :zip, namespace: true do
  prepare { require "zip" }

  start do
    Zip.setup do |configuration|
      configuration.default_compression = Zlib::BEST_COMPRESSION
      configuration.force_entry_names_encoding = "UTF-8"
      configuration.unicode_names = true
      configuration.validate_declared_number_of_entries = true
    end

    register :core, Zip
    register :output_stream, Zip::OutputStream
    register :file, Zip::File
  end
end
