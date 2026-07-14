# auto_register: false
# frozen_string_literal: true

module Terminus
  module Providers
    # The logger provider.
    class Logger < Hanami::Provider::Source
      RESOLVER = proc { Object.const_get "Cogger" }

      def initialize(environment: Hanami.env, resolver: RESOLVER, **)
        @environment = environment
        @resolver = resolver
        @id = Hanami.app.namespace.to_s.downcase.to_sym
        super(**)
      end

      def prepare = require "cogger"

      def start
        add_aliases
        add_filters
        register :logger, build_instance
      end

      private

      attr_reader :environment, :resolver, :id

      def add_aliases
        cogger.add_formatter(
          :rack,
          Cogger::Formatters::Emoji,
          "%<emoji:dynamic>s <dynamic>[%<id>s] [%<level>s] [%<at>s] %<verb>s " \
          "%<status>s %<elapsed>s %<ip>s %<path>s %<length>s </dynamic>"
        )

        cogger.add_formatter :sql,
                             Cogger::Formatters::Emoji,
                             "%<emoji:dynamic>s <dynamic>[%<id>s] [%<level>s] [%<at>s] %<db>s " \
                             "%<elapsed>s%<elapsed_unit>s %<query>s</dynamic>"
      end

      def add_filters
        cogger.add_filters :api_key,
                           :csrf,
                           :HTTP_ACCESS_TOKEN,
                           :HTTP_ID,
                           :mac_address,
                           :password,
                           :password_confirmation
      end

      def build_instance
        io = "log/#{environment}.log"

        case environment
          when :test
            cogger.new(id:, io: StringIO.new, formatter: :json, level: :debug).add_stream io:
          when :development then cogger.new(id:).add_stream(io:, formatter: :json)
          else cogger.new id:, formatter: :json
        end
      end

      def cogger
        @cogger ||= resolver.call
      end
    end
  end
end
