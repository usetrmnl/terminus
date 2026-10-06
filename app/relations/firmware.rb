# frozen_string_literal: true

module Terminus
  module Relations
    # The firmware relation.
    class Firmware < DB::Relation
      schema :firmware, infer: true do
        associations do
          has_many :firmware_models, relation: :firmware_model
          has_one :model, through: :firmware_model, relation: :model, as: :model
        end
      end

      def by_version_desc
        order Sequel.desc(Sequel.function(:string_to_array, :version, ".").cast("int[]"))
      end
    end
  end
end
