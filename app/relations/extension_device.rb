# frozen_string_literal: true

module Terminus
  module Relations
    # The extension and device join relation.
    class ExtensionDevice < DB::Relation
      schema :extension_device, infer: true do
        associations do
          belongs_to :extension, relation: :extension
          belongs_to :device, relation: :device
        end
      end

      def create_all id, device_ids
        associations = device_ids.map { |device_id| {extension_id: id, device_id:} }
        extension_device.changeset(:create, associations).commit
      end

      # :reek:TooManyStatements
      def update_all id, device_ids
        extension_device.where(extension_id: id).exclude(device_id: device_ids).delete

        old_ids = extension_device.where(extension_id: id, device_id: device_ids).map(:device_id)
        new_ids = device_ids.reject { |id| old_ids.include? id.to_i }
        associations = new_ids.map { |device_id| {extension_id: id, device_id:} }

        extension_device.changeset(:create, associations).commit
      end
    end
  end
end
