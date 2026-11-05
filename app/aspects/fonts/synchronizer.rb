# frozen_string_literal: true

require "refinements/pathname"

module Terminus
  module Aspects
    module Fonts
      # Synchronizes TRMNL Framework fonts for local use.
      class Synchronizer
        include Deps[:settings, "aspects.downloader"]
        include Dry::Monads[:result]

        using Refinements::Pathname

        def initialize(
          configuration_path: Hanami.app.root.join("config/fonts.yml"),
          root_uri: "https://trmnl.com/fonts",
          **
        )
          @configuration_path = configuration_path
          @root_uri = root_uri
          super(**)
        end

        def call
          root = settings.fonts_root.mkpath
          names = YAML.load_file(configuration_path).fetch "names"

          delete_unknown_files root, names
          names.map { download_to root, it }
        end

        private

        attr_reader :configuration_path, :root_uri

        def delete_unknown_files root, names
          root.files
              .map { it.basename.to_s }
              .then { |locals| locals - names }
              .each { root.join(it).delete }
        end

        def download_to root, name
          path = root.join name

          return Success path if path.exist?

          downloader.call("#{root_uri}/#{name}").fmap { |response| path.write response.body }
        end
      end
    end
  end
end
