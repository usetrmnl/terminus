# auto_register: false
# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Providers
    # The Sidekiq provider.
    class Sidekiq < Hanami::Provider::Source
      include Deps[:logger, extension_repository: "repositories.extension"]

      using Refinements::Hash

      RESOLVER = proc { Object.const_get "Sidekiq" }

      def initialize(resolver: RESOLVER, **)
        @resolver = resolver
        super(**)
      end

      def prepare
        require "sidekiq"
        require "sidekiq-scheduler"
        require "yaml"
      end

      def start
        configure_server
        configure_client
        load_schedules
        register :sidekiq, sidekiq
      end

      private

      attr_reader :resolver

      def configure_client
        sidekiq.configure_client do |configuration|
          configuration.redis = {url: slice[:settings].keyvalue_url}
          configuration.logger = slice[:logger]
        end
      end

      def configure_server
        sidekiq.configure_server do |configuration|
          # simplecov:disable
          configuration.redis = {url: slice[:settings].keyvalue_url}
          configuration.logger = slice[:logger]
        end
      end

      def load_schedules
        private_methods.tap { it.delete __method__ }
                       .grep(/load_/).each { __send__ it }
      end

      # :reek:TooManyStatements
      def load_static_schedules
        jobs = YAML.load_file slice.root.join("config/sidekiq_scheduler.yml")

        jobs.each do |name, configuration|
          sidekiq.set_schedule name, configuration
          job = configuration["class"]
          Object.const_get(job).perform_in 0
        rescue NameError, TypeError
          logger.error { "Unable to initialize job: #{job}." }
        end
      end

      def load_extension_schedules
        extension_repository.all.each { maybe_add_schedule(*it.to_schedule) }
      end

      def maybe_add_schedule name, configuration
        existing = sidekiq.get_schedule name

        return if configuration.empty? || existing.hash == configuration.stringify_keys.hash

        sidekiq.set_schedule name, configuration
      end

      def sidekiq
        @sidekiq ||= resolver.call
      end
    end
  end
end
