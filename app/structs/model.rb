# frozen_string_literal: true

require "core"
require "refinements/array"

module Terminus
  module Structs
    # The model struct.
    class Model < DB::Struct
      using Refinements::Array

      def css_classes
        size = css.dig "classes", "size"
        density = css.dig "classes", "density"

        %W[
          screen
          screen--#{name}
          screen--#{bit_depth}bit
          screen--#{orientation}
          #{size}
          #{density}
        ].compress
      end

      def css_variables
        css.fetch("variables", Core::EMPTY_ARRAY)
           .map { |(key, value)| "#{key}: #{value};" }
      end

      def export_attributes
        {
          label:,
          name:,
          description:,
          kind:,
          mime_type:,
          colors:,
          bit_depth:,
          rotation:,
          offset_x:,
          offset_y:,
          scale_factor:,
          width:,
          height:,
          css:
        }
      end

      def orientation = rotation.zero? ? "landscape" : "portrait"
    end
  end
end
