# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_enum :extension_exchange_verb_enum, %w[get post]

    create_table :extension_exchange do
      primary_key :id, type: :Bignum

      foreign_key :extension_id, :extension, null: false, on_update: :cascade, on_delete: :cascade

      column :headers, :jsonb, null: false, default: "{}"
      column :verb, :extension_exchange_verb_enum, null: false, default: "get"
      column :template, :text, null: false
      column :body, :jsonb, null: false, default: "{}"
      column :data, :jsonb, null: false, default: "{}"
      column :errors, :jsonb, null: false, default: "{}"
      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP

      index %i[extension_id template], unique: true
    end
  end
end
