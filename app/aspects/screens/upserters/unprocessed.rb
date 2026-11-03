# frozen_string_literal: true

require "dry/monads"
require "refinements/struct"

module Terminus
  module Aspects
    module Screens
      module Upserters
        # Creates screen record with image attachment from unprocessed image URI.
        class Unprocessed
          include Deps[
            "mini_magick.image",
            "aspects.screens.converter",
            repository: "repositories.screen"
          ]
          include Dry::Monads[:result]

          using Refinements::Struct

          def initialize(struct: Terminus::Structs::Screen.new, **)
            @struct = struct
            super(**)
          end

          def call(mold) = Pathname.mktmpdir { process mold, it }

          private

          attr_reader :struct

          def process mold, directory
            mold.with! input_path: Pathname(directory).join("input.png"),
                       output_path: directory.join(mold.file_name)

            image.open(mold.content)
                 .write(mold.input_path)
                 .then { converter.call mold }
                 .bind { |path| save mold, path }
          end

          def save(mold, path) = Success repository.upsert_with_image(path, mold, struct)
        end
      end
    end
  end
end
