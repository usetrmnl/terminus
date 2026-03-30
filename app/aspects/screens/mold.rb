# frozen_string_literal: true

module Terminus
  module Aspects
    module Screens
      # Defines the blueprint in which to create a screen.
      Mold = Struct.new(
        :model_id,
        :name,
        :label,
        :content,
        :mode,
        :mime_type,
        :bit_depth,
        :colors,
        :color_codes,
        :grays,
        :rotation,
        :offset_x,
        :offset_y,
        :width,
        :height,
        :input_path,
        :output_path
      ) do
        def color? = dither? && Array(color_codes).any?

        def crop = "#{dimensions}+#{offset_x}+#{offset_y}"

        def cropable? = !offset_x.zero? || !offset_y.zero?

        def dither? = mode == "dither"

        def dimensions = "#{width}x#{height}"

        def file_name = %(#{name}.#{mime_type.split("/").last})

        def file_type = mime_type.split("/").last.then { it.match?(/bmp/i) ? "bmp3" : it }

        def image? = mime_type.start_with? "image"

        def image_attributes = {model_id:, name:, label:}

        def rotatable? = !rotation.zero?

        def viewport = {width:, height:}
      end
    end
  end
end
