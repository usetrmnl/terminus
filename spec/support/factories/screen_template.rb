# frozen_string_literal: true

Factory.define :screen_template do |factory|
  factory.association :device
  factory.label "Test"
  factory.source "<h1>Test</h1>"
  factory.created_at { Time.now }
  factory.updated_at { Time.now }
end
