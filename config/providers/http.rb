# frozen_string_literal: true

Hanami.app.register_provider :http do
  prepare do
    require "connection_pool"
    require "http"
  end

  start do
    slice.start :logger

    http = ConnectionPool::Wrapper.new size: ENV.fetch("HANAMI_MAX_THREADS", 5) do
      HTTP.timeout(connect: 2, read: 10, write: 10)
          .use(:auto_inflate)
          .use(logging: {logger: slice[:logger]})
          .headers("User-Agent" => "http.rb/#{HTTP::VERSION} (#{Hanami.app.app_name})")
    end

    register :http, http
  end

  stop { slice[:http].close }
end
