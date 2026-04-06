# frozen_string_literal: true

Factory.define :extension_exchange, relation: :extension_exchange do |factory|
  factory.association :extension
  factory.headers Hash.new
  factory.verb "get"
  factory.sequence(:template) { "https://test.io/#{it}" }
  factory.body Hash.new
  factory.errors Hash.new
end
