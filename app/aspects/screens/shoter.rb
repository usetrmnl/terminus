# frozen_string_literal: true

require "dry/monads"
require "ferrum"
require "refinements/pathname"
require "refinements/string"

module Terminus
  module Aspects
    module Screens
      # Saves web page as screenshot.
      class Shoter
        include Deps[:settings, :logger]
        include Dry::Monads[:result]

        using Refinements::Pathname
        using Refinements::String

        OPTIONS = {
          "disable-dev-shm-usage" => nil,
          "disable-gpu" => nil,
          "hide-scrollbar" => nil,
          "no-sandbox" => nil
        }.freeze

        def initialize(browser: Ferrum::Browser, options: OPTIONS, **)
          super(**)
          @browser = browser
          @settings = settings.browser.merge! browser_options: options
        end

        def call(content, output_path, **viewport) = save content, viewport, output_path

        private

        attr_reader :settings, :browser

        def save content, viewport, output_path
          instance = browser.new settings
          page = instance.create_page

          Pathname.mktmpdir do |work_dir|
            page.content = work_dir.join("content.html").write(content).read
            page.set_viewport(**viewport)

            # Continuously check until `TRMNL_PLUGINS_READY` has been set to true.
            # The framework's plugin.js does that once it's done with its work
            # (like handling overflow etc.)
            wait = <<~EOT
              const resolve = arguments[0];
              const interval = setInterval(() => {
                if (window.TRMNL_PLUGINS_READY) {
                  clearInterval(interval);
                  resolve();
                }
              }, 100);
            EOT

            page.evaluate_async(wait, 10)
            page.screenshot path: output_path.to_s
          end

          instance.quit
          Success output_path
        rescue Ferrum::BrowserError => error then handle_browser_error instance, error
        rescue Ferrum::DeadBrowserError => error then handle_dead_browser_error error
        rescue Ferrum::TimeoutError => error then handle_timeout_error instance, error
        rescue Ferrum::NoSuchTargetError => error then handle_no_such_target_error instance, error
        rescue Ferrum::ProcessTimeoutError => error then handle_process_timeout_error error
        end

        def handle_browser_error instance, error
          instance.quit
          logger.debug { "Screen shoter has browser error: #{error.message}" }

          Failure "Unable to capture screenshot due to an instance error such as " \
                  "page navigation, element interaction, or something else."
        end

        def handle_dead_browser_error error
          logger.debug { "Screen shoter has dead browser: #{error.message}" }

          Failure "Unable to capture screenshot due to a dead browser. " \
                  "This could mean the browser crashed, server is out of memory, " \
                  "or a resource limitation has been hit."
        end

        def handle_timeout_error instance, error
          instance.quit if instance
          logger.debug { "Screen shoter has timeout: #{error.message}" }

          seconds = settings.fetch :timeout, 0

          Failure "Unable to capture screenshot due to timming out after " \
                  + %(#{seconds} #{"second".pluralize "s"}. ) \
                  + "This might have happened due to the page taking a long time to load."
        end

        def handle_no_such_target_error instance, error
          instance.quit
          logger.debug { "Screen shoter has no such target: #{error.message}" }
          Failure "Unable to capture screenshot because the page closed or crashed."
        end

        def handle_process_timeout_error error
          logger.debug { "Screen shoter has process timeout: #{error.message}" }

          seconds = settings.fetch :process_timeout, 0

          Failure "Unable to capture screenshot because the browser could not produce a " \
                  + %(websocket URL within #{seconds} #{"second".pluralize "s"}.)
        end
      end
    end
  end
end
