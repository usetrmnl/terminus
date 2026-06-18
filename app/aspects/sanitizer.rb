# frozen_string_literal: true

require "core"
require "refinements/array"
require "refinements/hash"
require "sanitize"

module Terminus
  module Aspects
    # A custom HTML sanitizer.
    class Sanitizer
      using Refinements::Array
      using Refinements::Hash

      def initialize configuration_path: Hanami.app.root.join("config/sanitize.yml"),
                     defaults: Sanitize::Config::RELAXED,
                     client: Sanitize
        @configuration_path = configuration_path
        @defaults = defaults
        @client = client
      end

      def call content
        YAML.load_file(configuration_path)
            .then { build_settings_for it }
            .then { defaults.deep_merge it }
            .then { client::Config.merge it }
            .then { client.document content, it }
      end

      private

      attr_reader :configuration_path, :defaults, :client

      def build_settings_for configuration
        {
          css: {
            properties: merge_properties(configuration)
          },
          elements: merge_elements(configuration),
          attributes: merge_attributes(configuration)
        }
      end

      def merge_properties configuration
        defaults.dig(:css, :properties).including configuration.fetch("css", Core::EMPTY_HASH)
                                                               .fetch("properties", Core::EMPTY_HASH)
      end

      def merge_elements configuration
        defaults[:elements].including configuration.fetch("elements")
      end

      def merge_attributes configuration
        defaults[:attributes].merge configuration.fetch("attributes") do |_element, default_attributes, custom_attributes|
          default_attributes.to_a.including(*custom_attributes)
        end
      end
    end
  end
end
