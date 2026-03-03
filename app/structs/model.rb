# frozen_string_literal: true

module Terminus
  module Structs
    # The model struct.
    class Model < DB::Struct
      def css_classes
        size = css.dig "classes", "size"

        "screen screen--#{name} screen--#{bit_depth}bit screen--#{orientation} " \
        "#{size} screen--1x".squeeze " "
      end

      def orientation = rotation.zero? ? "landscape" : "portrait"
    end
  end
end
