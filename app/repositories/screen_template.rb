# frozen_string_literal: true

module Terminus
  module Repositories
    # The screen template repository.
    class ScreenTemplate < DB::Repository[:screen_templates]
      commands :create, update: :by_pk, delete: :by_pk

      def all
        screen_templates.combine(:device)
                        .order { created_at.desc }
                        .to_a
      end

      def all_by_device id
        screen_templates.where(device_id: id)
                        .order { created_at.desc }
                        .to_a
      end

      def find(id) = (screen_templates.combine(:device).by_pk(id).one if id)
    end
  end
end
