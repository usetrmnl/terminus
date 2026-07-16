# frozen_string_literal: true

Hanami.app.register_provider :shrine do
  prepare do
    require "shrine"
    require "shrine/storage/file_system"
  end

  start do
    Shrine.storages = if Hanami.env? :test
                        {cache: Shrine::Storage::Memory.new, store: Shrine::Storage::Memory.new}
                      else
                        # simplecov:disable
                        {
                          cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
                          store: Shrine::Storage::FileSystem.new("public", prefix: "uploads")
                        }
                        # simplecov:enable
                      end

    Shrine.plugin :add_metadata
    Shrine.plugin :determine_mime_type, analyzer: :marcel
    Shrine.plugin :entity
    Shrine.plugin :signature
    Shrine.plugin :store_dimensions, analyzer: :mini_magick, on_error: proc { "Omit" }
    Shrine.plugin :validation_helpers

    Shrine.logger = slice[:logger]

    register :shrine, Shrine
  end
end
