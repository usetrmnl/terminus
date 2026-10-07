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

      def with_model_join(**)
        join(:firmware_model, firmware_id: :id).join(:model, id: firmware_model[:model_id])
                                               .where(**).to_a
      end

      def by_version_desc
        order Sequel.desc(Sequel.function(:string_to_array, :version, ".").cast("int[]"))
      end
    end
  end
end
