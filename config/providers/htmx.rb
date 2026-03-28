# frozen_string_literal: true

Hanami.app.register_provider :htmx do
  prepare { require "htmx" }

  start do
    register :htmx, HTMX
    register :htmx_defaults, {"allowScriptTags" => false, "defaultSwapStyle" => "outerHTML"}
  end
end
