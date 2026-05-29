# frozen_string_literal: true

require "uri"

module Terminus
  module Aspects
    module HomeAssistant
      # Adds *_url keys for relative Home Assistant URLs.
      class UrlNormalizer
        include Deps[:settings]

        def call payload, _base_url = nil
          normalize payload
        end

        private

        def normalize value
          case value
            when Hash then normalize_hash value
            when Array then value.map { normalize it }
            else value
          end
        end

        def normalize_hash value
          value.each_with_object({}) do |(key, item), all|
            all[key] = normalize item
            all["#{key}_url"] = proxied_url(item) if proxied_path? item
          end
        end

        def proxied_path? value
          value.is_a?(String) && value.match?(%r{\A(/api/|/local/)})
        end

        def proxied_url path
          "#{api_uri}/home-assistant/media?path=#{URI.encode_www_form_component path}"
        end

        def api_uri
          value = String(settings.api_uri).strip
          value.sub %r(/+\z), ""
        end
      end
    end
  end
end
