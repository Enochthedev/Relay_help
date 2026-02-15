class AddSocialFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :avatar_url, :string
    add_column :users, :language, :string
    add_column :users, :time_zone, :string
  end
end
