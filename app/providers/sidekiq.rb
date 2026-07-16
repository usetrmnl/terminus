# auto_register: false
# frozen_string_literal: true

module Terminus
  module Providers
    # The Sidekiq provider.
    class Sidekiq < Hanami::Provider::Source
      include Deps[:logger]

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
        # simplecov:disable
        sidekiq.configure_server do |configuration|
          configuration.redis = {url: slice[:settings].keyvalue_url}
          configuration.logger = slice[:logger]
          configuration.on(:startup) { load_schedule }
        end
        # simplecov:enable
      end

      def sidekiq
        @sidekiq ||= resolver.call
      end

      # simplecov:disable
      def load_schedule
        jobs = YAML.load_file slice.root.join("config/sidekiq_scheduler.yml")

        jobs.each do |schedule_name, options|
          resolver.call.set_schedule schedule_name, options
          job_name = options["class"]
          Object.const_get(job_name).perform_in 0
        rescue NameError, TypeError
          logger.error { "Unable to initialize job: #{job_name}." }
        end
      end
      # simplecov:enable
    end
  end
end
