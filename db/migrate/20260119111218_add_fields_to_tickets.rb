class AddFieldsToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :sla_target, :integer
    
    add_index :tickets, :category
    add_index :tickets, :subcategory
  end
end
