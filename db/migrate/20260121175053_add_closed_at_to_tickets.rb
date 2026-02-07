class AddClosedAtToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :closed_at, :datetime
    add_index :tickets, :closed_at
  end
end
