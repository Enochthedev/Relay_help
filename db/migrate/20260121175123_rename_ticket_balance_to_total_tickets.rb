class RenameTicketBalanceToTotalTickets < ActiveRecord::Migration[7.1]
  def change
     rename_column :customers, :ticket_balance, :total_tickets
  end
end
