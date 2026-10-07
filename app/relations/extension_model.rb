# frozen_string_literal: true

module Terminus
  module Relations
    # The extension and model join relation.
    class ExtensionModel < DB::Relation
      schema :extension_model, infer: true do
        associations do
          belongs_to :extension, relation: :extension
          belongs_to :model, relation: :model
        end
      end

      def create_all id, model_ids
        associations = model_ids.map { |model_id| {extension_id: id, model_id:} }
        extension_model.changeset(:create, associations).commit
      end

      # :reek:TooManyStatements
      def update_all id, model_ids
        extension_model.where(extension_id: id).exclude(model_id: model_ids).delete

        old_ids = extension_model.where(extension_id: id, model_id: model_ids).map(:model_id)
        new_ids = model_ids.reject { |id| old_ids.include? id.to_i }
        associations = new_ids.map { |model_id| {extension_id: id, model_id:} }

        extension_model.changeset(:create, associations).commit
      end
    end
  end
end
