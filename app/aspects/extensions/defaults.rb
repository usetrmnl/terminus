# frozen_string_literal: true

module Terminus
  module Aspects
    module Extensions
      DEFAULTS = {
        tags: [],
        mode: "light",
        kind: "poll",
        home_assistant_source_mode: "entity",
        home_assistant_entity_ids: "",
        home_assistant_endpoint_path: "/api/states",
        home_assistant_attribute_map: {},
        home_assistant_normalize_urls: true,
        verb: "get",
        start_at: Time.now.strftime("%Y-%m-%dT00:00:00"),
        days: [],
        interval: 1,
        template: <<~BODY
          <div class="{{ extension.css_classes }}">
            <div class="view view--full">
              <div class="layout layout--col">
              </div>
            </div>
          </div>
        BODY
      }.freeze
    end
  end
end
