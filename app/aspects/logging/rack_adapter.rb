# frozen_string_literal: true

module Terminus
  module Aspects
    module Logging
      # Adapts Cogger Rack middleware for provider registration.
      module RackAdapter
        module_function

        def with logger
          @logger ||= logger
          self
        end

        def new application
          @application = Cogger::Rack::Logger.new application, {logger: @logger}
        end

        def call(environment) = @application.call environment
      end
    end
  end
end
