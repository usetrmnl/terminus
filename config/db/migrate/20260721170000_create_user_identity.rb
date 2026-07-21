# frozen_string_literal: true

ROM::SQL.migration do
  up do
    create_table :user_identity do
      primary_key :id, type: :Bignum
      foreign_key :user_id, :user, null: false, type: :Bignum, on_delete: :cascade

      column :provider, String, null: false
      column :uid, String, null: false
      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP

      index %i[provider uid], unique: true
    end

    run %(GRANT SELECT, INSERT, UPDATE, DELETE ON user_identity TO CURRENT_USER)
  end

  down do
    drop_table :user_identity
  end
end
