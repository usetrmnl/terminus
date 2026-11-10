# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Chromium
    # Loads default configuration.
    class Loader
      using Refinements::Hash

      def initialize path = Pathname(__FILE__).expand_path.dirname.join("defaults.yml"),
                     model: Model
        @path = path
        @model = model
      end

      def call = model[**YAML.load_file(path).symbolize_keys!]

      private

      attr_reader :path, :model
    end
  end
end
