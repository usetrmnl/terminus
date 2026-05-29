# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run "ALTER TYPE extension_kind_enum ADD VALUE IF NOT EXISTS 'home_assistant';"

    create_table :home_assistant_connection do
      primary_key :id, type: :Bignum

      column :enabled, :boolean, null: false, default: false
      column :base_url, :text
      column :access_token, :text
      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    create_table :extension_home_assistant_config do
      primary_key :id, type: :Bignum

      foreign_key :extension_id,
                  :extension,
                  type: :Bignum,
                  null: false,
                  unique: true,
                  on_delete: :cascade
      column :source_mode, :text, null: false, default: "entity"
      column :entity_ids, "text[]", null: false, default: "{}"
      column :endpoint_path, :text
      column :attribute_map, :jsonb, null: false, default: "{}"
      column :normalize_urls, :boolean, null: false, default: true
      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :extension_home_assistant_config
    drop_table :home_assistant_connection
  end
end
