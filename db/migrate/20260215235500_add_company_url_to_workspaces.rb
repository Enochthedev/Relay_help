class AddCompanyUrlToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :workspaces, :company_url, :string
  end
end
