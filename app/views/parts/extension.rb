# frozen_string_literal: true

require "dry/core"
require "hanami/view"
require "initable"

module Terminus
  module Views
    module Parts
      # The extension presenter.
      class Extension < Hanami::View::Part
        include Initable[json_formatter: Aspects::JSONFormatter]

        def alpine_tags
          Array(tags).map { %('#{it}') }
                     .join(",")
                     .then { "[#{it}]" }
        end

        def formatted_body = json_formatter.call body

        def formatted_data = json_formatter.call data

        def formatted_days = days ? days.join(",") : ""

        def formatted_fields = json_formatter.call fields

        def formatted_headers = json_formatter.call headers

        def formatted_home_assistant_attribute_map
          config = extension_home_assistant_config
          return "{}" unless config

          json_formatter.call config.attribute_map
        end

        def formatted_home_assistant_entity_ids
          config = extension_home_assistant_config
          return "" unless config

          Array(config.entity_ids).join "\n"
        end

        def home_assistant_source_mode
          config = extension_home_assistant_config
          config ? config.source_mode : "entity"
        end

        def home_assistant_entity_ids = formatted_home_assistant_entity_ids

        def home_assistant_endpoint_path
          config = extension_home_assistant_config
          config ? config.endpoint_path : "/api/states"
        end

        def home_assistant_attribute_map = formatted_home_assistant_attribute_map

        def home_assistant_normalize_urls
          return true unless extension_home_assistant_config

          extension_home_assistant_config.normalize_urls
        end

        def formatted_uris = uris.join "\n"

        def formatted_start_at
          start_at ? start_at.strftime("%Y-%m-%dT%H:%M:%S") : "2025-01-01T00:00:00"
        end
      end
    end
  end
end
