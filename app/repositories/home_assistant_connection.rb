# frozen_string_literal: true

module Terminus
  module Repositories
    # The home assistant connection repository.
    class HomeAssistantConnection < DB::Repository[:home_assistant_connection]
      commands :create

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def current
        home_assistant_connection.order { id.asc }
                                 .one
      end

      def current_or_initialize
        current || create(enabled: false, base_url: nil, access_token: nil)
      end
    end
  end
end
