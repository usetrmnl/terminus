# frozen_string_literal: true

require "sidekiq/web"

require "sidekiq-scheduler/web"

require_relative "../app/aspects/screens/designer/middleware"

module Terminus
  # The application base routes.
  # rubocop:todo Metrics/ClassLength
  class Routes < Hanami::Routes
    slice(:authentication, at: "/") { use Authentication::Middleware }

    mount Sidekiq::Web, at: "/sidekiq"

    get "/", to: "dashboard.show", as: :root

    # rubocop:todo Metrics/BlockLength
    scope "api" do
      get "/devices", to: "api.devices.index", as: :devices
      get "/devices/:id", to: "api.devices.show", as: :device
      post "/devices", to: "api.devices.create", as: :device_create
      patch "/devices/:id", to: "api.devices.patch", as: :device_patch
      delete "/devices/:id", to: "api.devices.delete", as: :device_delete

      resource :display, to: "api.display", only: :show

      get "/firmware", to: "api.firmware.index", as: :firmware
      get "/firmware/:id", to: "api.firmware.show", as: :firmware_show
      post "/firmware", to: "api.firmware.create", as: :firmware_create
      patch "/firmware/:id", to: "api.firmware.patch", as: :firmware_patch
      delete "/firmware/:id", to: "api.firmware.delete", as: :firmware_delete

      resource :log, to: "api.log", only: :create

      get "/models", to: "api.models.index", as: :models
      get "/models/:id", to: "api.models.show", as: :model
      post "/models", to: "api.models.create", as: :model_create
      patch "/models/:id", to: "api.models.patch", as: :model_patch
      delete "/models/:id", to: "api.models.delete", as: :model_delete

      get "/playlists", to: "api.playlists.index", as: :playlists
      get "/playlists/:id", to: "api.playlists.show", as: :playlist
      post "/playlists", to: "api.playlists.create", as: :playlist_create
      patch "/playlists/:id", to: "api.playlists.patch", as: :playlist_patch
      delete "/playlists/:id", to: "api.playlists.delete", as: :playlist_delete

      get "/screens", to: "api.screens.index", as: :screens
      post "/screens", to: "api.screens.create", as: :screen_create
      patch "/screens/:id", to: "api.screens.patch", as: :screen_patch
      delete "/screens/:id", to: "api.screens.delete", as: :screen_delete

      resource :setup, to: "api.setup", only: :show
    end
    # rubocop:enable Metrics/BlockLength

    scope "bulk" do
      delete "/devices/:device_id/logs", to: "bulk.devices.logs.delete", as: :device_logs_delete
      delete "/firmware", to: "bulk.firmware.delete", as: :firmware_delete
    end

    get "/devices", to: "devices.index", as: :devices
    get "/devices/:id", to: "devices.show", as: :device
    get "/devices/new", to: "devices.new", as: :device_new
    post "/devices", to: "devices.create", as: :device_create
    get "/devices/:id/edit", to: "devices.edit", as: :device_edit
    put "/devices/:id", to: "devices.update", as: :device_update
    delete "/devices/:id", to: "devices.delete", as: :device_delete

    get "/devices/:device_id/logs", to: "devices.logs.index", as: :device_logs
    get "/devices/:device_id/logs/:id", to: "devices.logs.show", as: :device_log
    delete "/devices/:device_id/logs/:id", to: "devices.logs.delete", as: :device_log_delete

    resource :designer, to: "designer", only: %i[show create]

    get "/extensions", to: "extensions.index", as: :extensions
    get "/extensions/new", to: "extensions.new", as: :extension_new
    post "/extensions", to: "extensions.create", as: :extension_create
    get "/extensions/:id/edit", to: "extensions.edit", as: :extension_edit
    put "/extensions/:id", to: "extensions.update", as: :extension_update
    delete "/extensions/:id", to: "extensions.delete", as: :extension_delete

    get "/extensions/gallery", to: "extensions.gallery.index", as: :extensions_gallery

    post "/extensions/:extension_id/build",
         to: "extensions.build.create",
         as: :extension_build_create

    get "/extensions/:extension_id/clone/new", to: "extensions.clone.new", as: :extension_clone_new
    post "/extensions/:extension_id/clone",
         to: "extensions.clone.create",
         as: :extension_clone_create

    get "/extensions/:extension_id/exchanges",
        to: "extensions.exchanges.index",
        as: :extension_exchanges
    get "/extensions/:extension_id/exchanges/new",
        to: "extensions.exchanges.new",
        as: :extension_exchange_new
    post "/extensions/:extension_id/exchanges",
         to: "extensions.exchanges.create",
         as: :extension_exchanges
    get "/extensions/:extension_id/exchanges/:id/edit",
        to: "extensions.exchanges.edit",
        as: :extension_exchange_edit
    put "/extensions/:extension_id/exchanges/:id",
        to: "extensions.exchanges.update",
        as: :extension_exchange
    delete "/extensions/:extension_id/exchanges/:id",
           to: "extensions.exchanges.delete",
           as: :extension_exchange

    get "/extensions/:extension_id/preview", to: "extensions.preview.show", as: :extension_preview
    get "/extensions/:extension_id/sources", to: "extensions.sources.index", as: :extension_sources
    get "/extensions/:extension_id/sensors", to: "extensions.sensors.index", as: :extension_sensors

    get "/firmware", to: "firmware.index", as: :firmware
    get "/firmware/:id", to: "firmware.show", as: :firmware_show
    get "/firmware/new", to: "firmware.new", as: :firmware_new
    post "/firmware", to: "firmware.create", as: :firmware_create
    get "/firmware/:id/edit", to: "firmware.edit", as: :firmware_edit
    put "/firmware/:id", to: "firmware.update", as: :firmware_update
    delete "/firmware/:id", to: "firmware.delete", as: :firmware_delete

    get "/models", to: "models.index", as: :models
    get "/models/:id", to: "models.show", as: :model
    get "/models/new", to: "models.new", as: :model_new
    post "/models", to: "models.create", as: :model_create
    get "/models/:id/edit", to: "models.edit", as: :model_edit
    put "/models/:id", to: "models.update", as: :model_update
    delete "/models/:id", to: "models.delete", as: :model_delete

    get "/models/:model_id/clone/new", to: "models.clone.new", as: :model_clone_new
    post "/models/:model_id/clone", to: "models.clone.create", as: :model_clone_create

    get "/playlists", to: "playlists.index", as: :playlists
    get "/playlists/:id", to: "playlists.show", as: :playlist
    get "/playlists/new", to: "playlists.new", as: :playlist_new
    post "/playlists", to: "playlists.create", as: :playlist_create
    get "/playlists/:id/edit", to: "playlists.edit", as: :playlist_edit
    put "/playlists/:id", to: "playlists.update", as: :playlist_update
    delete "/playlists/:id", to: "playlists.delete", as: :playlist_delete

    get "/playlists/:playlist_id/clone/new", to: "playlists.clone.new", as: :playlist_clone_new
    post "/playlists/:playlist_id/clone", to: "playlists.clone.create", as: :playlist_clone_create

    get "/playlists/:playlist_id/items", to: "playlists.items.index", as: :playlist_items
    get "/playlists/:playlist_id/items/:id", to: "playlists.items.show", as: :playlist_item
    get "/playlists/:playlist_id/items/new", to: "playlists.items.new", as: :playlist_item_new
    post "/playlists/:playlist_id/items", to: "playlists.items.create", as: :playlist_item_create
    get "/playlists/:playlist_id/items/:id/edit",
        to: "playlists.items.edit",
        as: :playlist_item_edit
    put "/playlists/:playlist_id/items/:id", to: "playlists.items.update", as: :playlist_item_update
    delete "/playlists/:playlist_id/items/:id",
           to: "playlists.items.delete",
           as: :playlist_item_delete

    get "/playlists/:playlist_id/mirror/edit",
        to: "playlists.mirror.edit",
        as: :playlist_mirror_edit
    put "/playlists/:playlist_id/mirror", to: "playlists.mirror.update", as: :playlist_mirror_update

    get "/playlists/:playlist_id/screens", to: "playlists.screens.index", as: :playlist_screens
    get "/playlists/:playlist_id/screens/:id", to: "playlists.screens.show", as: :playlist_screen

    resources :problem_details, to: "problem_details", only: :index, as: :problem_details

    get "/screens", to: "screens.index", as: :screens
    get "/screens/:id", to: "screens.show", as: :screen
    get "/screens/new", to: "screens.new", as: :screen_new
    post "/screens", to: "screens.create", as: :screen_create
    get "/screens/:id/edit", to: "screens.edit", as: :screen_edit
    put "/screens/:id", to: "screens.update", as: :screen_update
    delete "/screens/:id", to: "screens.delete", as: :screen_delete

    get "/users", to: "users.index", as: :users
    get "/users/:id", to: "users.show", as: :user
    get "/users/new", to: "users.new", as: :user_new
    post "/users", to: "users.create", as: :user_create
    get "/users/:id/edit", to: "users.edit", as: :user_edit
    put "/users/:id", to: "users.update", as: :user_update

    slice(:health, at: "/up") { root to: "show" }

    use Rack::Static, root: "public", urls: ["/.well-known/security.txt", "/fonts", "/uploads"]
    use Aspects::Screens::Designer::Middleware, pattern: %r(/preview/(?<name>.+))
  end
  # rubocop:enable Metrics/ClassLength
end
