class AddTimezoneAndLanguageToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :workspaces, :time_zone, :string
    add_column :workspaces, :language, :string
  end
end
