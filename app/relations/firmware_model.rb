# frozen_string_literal: true

module Terminus
  module Relations
    # The firmware and model join relation.
    class FirmwareModel < DB::Relation
      schema :firmware_model, infer: true do
        associations do
          belongs_to :firmware, relation: :firmware
          belongs_to :model, relation: :model
        end
      end

      def create_all id, model_ids
        associations = model_ids.map { |model_id| {firmware_id: id, model_id:} }
        firmware_model.changeset(:create, associations).commit
      end

      # :reek:TooManyStatements
      def update_all id, model_ids
        firmware_model.where(firmware_id: id).exclude(model_id: model_ids).delete

        old_ids = firmware_model.where(firmware_id: id, model_id: model_ids).map(:model_id)
        new_ids = model_ids.reject { |id| old_ids.include? id.to_i }
        associations = new_ids.map { |model_id| {firmware_id: id, model_id:} }

        firmware_model.changeset(:create, associations).commit
      end
    end
  end
end
