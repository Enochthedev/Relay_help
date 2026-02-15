class CreateIdentities < ActiveRecord::Migration[7.1]
  def change
    create_table :identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider
      t.string :uid
      t.string :email
      t.string :name
      t.string :avatar_url
      t.json :raw_info

      t.timestamps
    end
  end
end
