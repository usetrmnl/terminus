# frozen_string_literal: true

Hanami.app.register_provider :htmx do
  prepare { require "htmx" }

  start do
    toggler = lambda do |request, default = "app"|
      HTMX.request?(request.env, :request, "true") ? false : default
    end

    register :htmx, HTMX
    register :htmx_defaults, {"defaultSwap" => "outerHTML"}.freeze
    register :htmx_layout, toggler
  end
end
