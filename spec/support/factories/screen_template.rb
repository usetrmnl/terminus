# frozen_string_literal: true

Factory.define :screen_template, relation: :screen_template do |factory|
  factory.sequence(:label) { "Template #{it}" }
  factory.sequence(:name) { "template_#{it}" }
  factory.content "<h1>Test</h1>"
  factory.created_at { Time.now }
  factory.updated_at { Time.now }
end
