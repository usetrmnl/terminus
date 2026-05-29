# frozen_string_literal: true

Factory.define :home_assistant_connection, relation: :home_assistant_connection do |factory|
  factory.enabled true
  factory.base_url "http://homeassistant.local:8123"
  factory.access_token "token123"
end
