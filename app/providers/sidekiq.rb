# auto_register: false
# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Providers
    # The Sidekiq provider.
    class Sidekiq < Hanami::Provider::Source
      RESOLVER = proc { Object.const_get "Sidekiq" }

      include Deps[:logger]

      using Refinements::Hash

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
        sidekiq.configure_server do |configuration|
          # simplecov:disable
          configuration.redis = {url: slice[:settings].keyvalue_url}
          configuration.logger = slice[:logger]
        end
      end

      def sidekiq
        @sidekiq ||= resolver.call
      end
    end
  end
end
