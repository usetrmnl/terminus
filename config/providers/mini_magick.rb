# frozen_string_literal: true

require "refinements/pathname"

using Refinements::Pathname

Hanami.app.register_provider :mini_magick, namespace: true do
  prepare { require "mini_magick" }

  start do
    MiniMagick.configure do |config|
      config.errors = true
      config.warnings = true
      config.restricted_env = true
      config.tmpdir = slice.root.join("tmp/mini_magick").make_ancestors.make_dir
      config.logger = slice[:logger]
    end

    register :core, MiniMagick
    register :image, MiniMagick::Image
  end
end
