# frozen_string_literal: true

require "yaml"

module Terminus
  module Aspects
    module Models
      # Exports a model for sharing.
      class Exporter
        include Deps[:settings, "aspects.zipper", palette_repository: "repositories.palette"]

        def call model
          zipper.call({"configuration.yml" => configuration_for(model)})
        end

        private

        def configuration_for model
          YAML.dump build_configuration(model), stringify_names: true
        end

        def build_configuration model
          {
            version: settings.git_tag,
            **model.export_attributes,
            default_palette_name: default_palette_name(model)
          }
        end

        def default_palette_name model
          palette_repository.find(model.default_palette_id).then { it.name if it }
        end
      end
    end
  end
end
