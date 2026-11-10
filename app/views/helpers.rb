# frozen_string_literal: true

require "core"
require "htmx"
require "refinements/hash"
require "refinements/string"

module Terminus
  module Views
    # The view helpers.
    module Helpers
      extend Hanami::View::Helpers::TagHelper

      using Refinements::Hash
      using Refinements::String

      DEFAULT_OPTION = ["Select...", Core::EMPTY_STRING].freeze

      module_function

      def boolean value
        css_class = value == true ? "bit-text-green" : "bit-text-red"
        tag.span value.to_s, class: css_class
      end

      def default_option records, selection, key_map: Core::EMPTY_HASH
        label, id = build_label_and_id key_map

        records.find { it.public_send(label) == selection }
               .then { it ? [it.public_send(label), it.public_send(id)] : ["Select...", nil] }
      end

      def field_included? key, value, attributes, record = nil
        ((record && record.public_send(key)) || attributes[key]).include? value
      end

      def field_for key, attributes, record = nil, errors: Core::EMPTY_HASH, prefix: "formatted_"
        real_key = String(key).delete_prefix(prefix).to_sym

        return attributes[key] unless record

        value = if errors.key? real_key
                  attributes[real_key]
                else
                  attributes.fetch_value key, record.public_send(key)
                end

        to_time value
      end

      def git_link kernel: Kernel
        settings = Hanami.app[:settings]
        tag_sha = kernel.`("git rev-parse --quiet --short #{settings.git_tag}^{}").strip

        tag_sha == settings.git_latest_sha ? git_version_link : git_latest_link
      end

      def git_latest_link
        settings = Hanami.app[:settings]

        link_to "Latest (ahead of #{settings.git_tag})",
                "https://github.com/usetrmnl/terminus/commit/#{settings.git_latest_sha}",
                class: :link
      end

      def git_version_link
        tag = Hanami.app[:settings].git_tag

        link_to "Version #{tag}",
                "https://alchemists.io/projects/terminus/versions/#{tag}/",
                class: :link
      end

      def human_at(value) = (value.strftime "%B %d %Y at %I:%M %p" if value)

      def human_time(value) = (value.strftime "%I:%M %p" if value)

      def pluralize value, suffix, count = 0
        %(#{count} #{value.pluralize suffix, count})
      end

      def select_options list, default: DEFAULT_OPTION
        list.reduce([default]) { |options, (name, label)| options.append [label, name] }
      end

      def select_options_for records, key_map: Core::EMPTY_HASH, default: DEFAULT_OPTION
        label, id = build_label_and_id key_map

        records.reduce [default] do |options, record|
          options.append [record.public_send(label), record.public_send(id)]
        end
      end

      def size value, kilobyte: 1_024, units: %w[B KB MB GB TB]
        bytes = value.to_f
        index = 0

        while bytes >= kilobyte && index < units.length - 1
          bytes /= kilobyte
          index += 1
        end

        "#{bytes.round 2} #{units[index]}"
      end

      def build_label_and_id key_map, defaults: {label: :label, id: :id}
        defaults.merge(key_map).values_at :label, :id
      end

      def to_time value
        case value
          when Sequel::SQLTime then value.strftime("%H:%M:%S")
          when Time then value.strftime("%Y-%m-%dT%H:%M")
          else value
        end
      end

      private_class_method :build_label_and_id, :to_time
    end
  end
end
