# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_enum :extension_kind_enum, %w[home_assistant image poll secure static webhook]
    create_enum :extension_verb_enum, %w[get post]
    create_enum :extension_unit_enum, %w[none minute hour day week month]

    create_table :extension do
      primary_key :id, type: :Bignum

      column :name, String, unique: true, index: true, null: false
      column :label, String, unique: true, null: false
      column :logo_data, :jsonb, null: false, default: "{}"
      column :description, :text
      column :kind, :extension_kind_enum, null: false, default: "poll"
      column :tags, "text[]", null: false, default: "{}"
      column :headers, :jsonb, null: false, default: "{}"
      column :verb, :extension_verb_enum, null: false, default: "get"
      column :uris, "text[]", null: false, default: "{}"
      column :body, :jsonb, null: false, default: "{}"
      column :fields, :jsonb, null: false, default: "{}"
      column :template, :text
      column :data, :jsonb, null: false, default: "{}"
      column :interval, Integer, null: false, default: 1
      column :unit, :extension_unit_enum, index: true, null: false, default: "none"
      column :days, "text[]", null: false, default: "{}"
      column :last_day_of_month, :boolean, null: false, default: false
      column :start_at,
             :timestamp,
             null: false,
             default: Sequel.function(:date_trunc, "day", Sequel::CURRENT_TIMESTAMP)
      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
