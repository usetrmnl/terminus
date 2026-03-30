# frozen_string_literal: true

module Terminus
  module Aspects
    module Screens
      module Converters
        # Converts to monochrome image.
        class Monochrome
          include Deps[mini_magick: "mini_magick.core"]
          include Dry::Monads[:result]

          def call mold
            route mold
          rescue MiniMagick::Error => error
            Failure error.message
          end

          private

          def route mold
            case mold
              in bit_depth: 1, mode: "dither" then as_one_bit_dither mold
              in bit_depth: 2..4, mode: "dither" then as_two_to_four_bit_dither mold
              in bit_depth: 8, mode: "dither" then as_eight_bit_dither mold
              in bit_depth: 1 then as_one_bit mold
              in bit_depth: 2..8 then as_two_to_eight_bit mold
              else Failure "Unsupported monochrome bit depth: #{mold.bit_depth}."
            end
          end

          def as_one_bit_dither mold
            convert mold do |tool|
              tool.dither "FloydSteinberg"
              tool.remap "pattern:gray50"
            end
          end

          def as_two_to_four_bit_dither mold
            convert mold do |tool|
              tool.colorspace "Gray"
              tool.dither "FloydSteinberg"
              tool.posterize mold.grays
            end
          end

          def as_eight_bit_dither mold
            convert mold do |tool|
              tool.type "Grayscale"
            end
          end

          def as_one_bit mold
            convert mold do |tool|
              tool.monochrome
              tool.colors mold.colors
            end
          end

          def as_two_to_eight_bit mold
            convert mold do |tool|
              tool.colorspace "Gray"
              tool.dither "None"
              tool.posterize mold.grays
            end
          end

          def convert mold
            output_path = mold.output_path

            mini_magick.convert do |tool|
              tool << mold.input_path.to_s
              tool.rotate mold.rotation if mold.rotatable?
              tool.resize "#{mold.dimensions}!"
              tool.crop mold.crop if mold.cropable?
              yield tool
              tool.alpha "off"
              tool.depth mold.bit_depth
              tool.strip
              tool << "#{mold.file_type}:#{output_path}"
            end

            Success output_path
          end
        end
      end
    end
  end
end
