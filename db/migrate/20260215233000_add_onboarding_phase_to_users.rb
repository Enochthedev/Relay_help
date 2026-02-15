class AddOnboardingPhaseToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :onboarding_phase, :string, default: "created"
  end
end
