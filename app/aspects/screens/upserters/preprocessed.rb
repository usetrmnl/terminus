# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Screens
      module Upserters
        # Creates screen record with image attachment from preprocesed image URI.
        class Preprocessed
          include Deps["mini_magick.image", repository: "repositories.screen"]
          include Dry::Monads[:result]

          def initialize(struct: Terminus::Structs::Screen.new, **)
            @struct = struct
            super(**)
          end

          def call(mold) = Pathname.mktmpdir { process mold, it }

          private

          attr_reader :struct

          def process mold, directory
            path = Pathname(directory).join "input.png"
            image.open(mold.content).write(path).then { save mold, path }
          end

          def save(mold, path) = Success repository.upsert_with_image(path, mold, struct)
        end
      end
    end
  end
end
