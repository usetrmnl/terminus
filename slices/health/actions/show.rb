# frozen_string_literal: true

module Health
  module Actions
    # The show action.
    class Show < Health::Action
      handle_exception Exception => :down

      def handle(*, response) = response.render view, color: :green

      protected

      def authorize(*) = nil

      private

      def down(*, response, _exception) = response.render view, color: :red, status: 503
    end
  end
end
