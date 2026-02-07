class AddInvitationFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Invitation tracking
    add_column :users, :invitation_status, :string, default: "pending"
    add_column :users, :invitation_token, :string
    add_column :users, :invitation_sent_at, :datetime
    add_column :users, :invitation_accepted_at, :datetime
    
    # Security
    add_column :users, :two_factor_verified, :boolean, default: false, null: false
    add_column :users, :email_verified_at, :datetime
    add_column :users, :discord_connected_at, :datetime
    
    # Make password optional for agents
    change_column_null :users, :encrypted_password, true
    change_column_default :users, :encrypted_password, from: "", to: nil
    
    # Indexes
    add_index :users, :invitation_token, unique: true
    add_index :users, :invitation_status
    add_index :users, :two_factor_verified
  end
end
