# frozen_string_literal: true

Factory.define :firmware_model, relation: :firmware_model do |factory|
  factory.association :firmware
  factory.association :model
end
