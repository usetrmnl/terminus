# frozen_string_literal: true

Factory.define :extension, relation: :extension do |factory|
  factory.sequence(:name) { "extension_#{it}" }
  factory.sequence(:label) { "Extension #{it}" }
  factory.mode "text"
  factory.kind "poll"
  factory.tags []
  factory.template "<h1>{{source_1.label}}</h1>"
  factory.data Hash.new
  factory.fields []
  factory.start_at Time.utc(2025, 1, 1, 0, 0, 0)
  factory.interval 1
  factory.unit "none"
  factory.days []
  factory.last_day_of_month false

  factory.trait :with_logo do |trait|
    trait.logo_data do
      {
        id: "logo.png",
        storage: "store",
        metadata: {
          bit_depth: 16,
          filename: "logo.png",
          height: 512,
          mime_type: "image/png",
          size: 50,
          width: 512
        }
      }
    end
  end
end
