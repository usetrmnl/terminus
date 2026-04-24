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

      module_function

      def boolean value
        css_class = value == true ? "bit-text-green" : "bit-text-red"
        tag.span value.to_s, class: css_class
      end

      # rubocop:todo Metrics/ParameterLists
      def field_included? key, value, attributes, record = nil
        ((record && record.public_send(key)) || attributes[key]).include? value
      end
      # rubocop:enable Metrics/ParameterLists

      def field_for key, attributes, record = nil
        return attributes[key] unless record

        value = attributes.fetch_value key, record.public_send(key)

        case value
          when Sequel::SQLTime then value.strftime("%H:%M:%S")
          when Time then value.strftime("%Y-%m-%dT%H:%M")
          else value
        end
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
                "https://github.com/usetrmnl/terminus/releases/tag/#{tag}",
                class: :link
      end

      def human_at(value) = (value.strftime "%B %d %Y at %H:%M %Z" if value)

      def human_time(value) = (value.strftime "%I:%M %p" if value)

      def pluralize value, suffix, count = 0
        %(#{count} #{value.pluralize suffix, count})
      end

      def select_options_for records, label: :label, id: :id
        records.reduce [["Select...", Core::EMPTY_STRING]] do |options, record|
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
    end
  end
end
