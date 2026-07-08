# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Screens
      # Finds or creates record with image attachment using only HTML content.
      class FindOrCreator
        include Deps[
          "aspects.screens.temp_pather",
          "aspects.screens.mold_builder",
          repository: "repositories.screen"
        ]
        include Initable[struct: proc { Terminus::Structs::Screen.new }]
        include Dry::Monads[:result]

        def call(**)
          mold_builder.call(**).bind do |mold|
            record = find mold
            record ? Success(record) : create(mold)
          end
        end

        private

        def find mold
          repository.find_by device_id: mold.device_id, model_id: mold.model_id, kind: mold.kind
        end

        def create mold
          temp_pather.call mold do |path|
            Success repository.create_with_image(path, mold, struct)
          end
        end
      end
    end
  end
end
