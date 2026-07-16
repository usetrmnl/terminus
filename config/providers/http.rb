# frozen_string_literal: true

Hanami.app.register_provider :http do
  prepare do
    require "connection_pool"
    require "http"
  end

  start do
    slice.start :logger

    connect, read, write = slice[:settings].to_h.values_at :http_timeout_connect,
                                                           :http_timeout_read,
                                                           :http_timeout_write

    http = ConnectionPool::Wrapper.new size: ENV.fetch("HANAMI_MAX_THREADS", 5) do
      HTTP.timeout(connect:, read:, write:)
          .use(:auto_inflate)
          .use(logging: {logger: slice[:logger]})
          .headers("User-Agent" => "http.rb/#{HTTP::VERSION} (#{Hanami.app.app_name})")
    end

    register :http, http
  end

  # simplecov:disable
  stop { slice[:http].close }
  # simplecov:enable
end
