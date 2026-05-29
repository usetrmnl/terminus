# frozen_string_literal: true

module Terminus
  module Repositories
    # The extension home assistant config repository.
    class ExtensionHomeAssistantConfig < DB::Repository[:extension_home_assistant_config]
      commands :create

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def find_by_extension_id extension_id:
        extension_home_assistant_config.where(extension_id: extension_id.to_i).one
      end

      def upsert_by_extension_id extension_id:, **attributes
        lookup_extension_id = extension_id.to_i
        record = find_by_extension_id extension_id: lookup_extension_id

        if record
          update record.id, attributes
        else
          create extension_id: lookup_extension_id, **attributes
        end
      end
    end
  end
end
