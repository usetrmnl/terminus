# frozen_string_literal: true

require "concurrent/atomic/read_write_lock"
require "dry/monads"
require "ferrum"
require "initable"
require "inspectable"
require "refinements/hash"
require "refinements/string"

module Terminus
  module Chromium
    # A headless browser.
    class Browser
      include Deps[:settings, :i18n, :logger]
      include Initable[
        options_map: {
          ferrum_default_timeout: :timeout,
          ferrum_process_timeout: :process_timeout,
          ferrum_javascript_errors: :js_errors
        }
      ]
      include Dry::Monads[:result]
      include Inspectable[i18n: :type, client: :type]

      using Refinements::Hash
      using Refinements::String

      def initialize(
        configuration: Terminus::Chromium::Loader.new.call,
        client: Ferrum::Browser,
        **
      )
        super(**)
        @configuration = configuration
        @application_options = settings.to_h.slice(*options_map.keys).transform_keys!(options_map)
        @client = client.new configuration.merge_options(application_options)
        @lock = Concurrent::ReadWriteLock.new
        @renders = 0
        @recoveries = 0

        log_options
      rescue Ferrum::ProcessTimeoutError => error
        handle_process_timeout
        raise error
      end

      def call(&)
        loop do
          lock.with_read_lock { client.create_page(&) }
          maybe_restart

          self.recoveries = 0

          return Success()
        rescue Ferrum::DeadBrowserError
          return handle_dead_browser unless maybe_recover
        end
      rescue Ferrum::BrowserError then handle_browser_error
      rescue Ferrum::NoSuchTargetError => error then handle_no_such_target error
      rescue Ferrum::TimeoutError then handle_timeout
      end

      def quit = lock.with_write_lock { client.quit }

      private

      attr_accessor :client, :renders, :recoveries
      attr_reader :application_options, :configuration, :lock

      def log_options
        logger.debug do
          {
            tags: [application_options, configuration.browser_options],
            message: i18n.translate("aspects.browser.options")
          }
        end
      end

      def maybe_restart
        lock.with_write_lock do
          maximum = configuration.maximum_renders

          return if (self.renders += 1) < maximum

          restart
          logger.debug { i18n.translate "aspects.browser.restart", maximum: }
        end
      end

      def maybe_recover
        lock.with_write_lock do
          return if (self.recoveries += 1) > configuration.maximum_recoveries

          restart
        rescue Ferrum::Error => error
          logger.error { i18n.translate "aspects.browser.recovery", message: error.message }
          false
        end
      end

      def restart
        self.renders = 0
        client.restart
      end

      def handle_process_timeout
        logger.fatal do
          seconds = application_options.fetch :process_timeout, 0

          i18n.translate "aspects.browser.process_timeout",
                         seconds:,
                         label: "second".pluralize("s", seconds)
        end
      end

      def handle_dead_browser
        logger.warn { i18n.translate "aspects.browser.dead" }
        Success()
      end

      def handle_browser_error
        message = i18n.translate "aspects.browser.error"

        logger.error { message }
        Failure message
      end

      def handle_no_such_target error
        message = i18n.translate "aspects.browser.no_target", message: error.message

        logger.error { message }
        Failure message
      end

      def handle_timeout
        seconds = application_options.fetch :timeout, 0
        message = i18n.translate "aspects.browser.timeout",
                                 seconds:,
                                 label: "second".pluralize("s", seconds)

        logger.error { message }
        Failure message
      end
    end
  end
end
