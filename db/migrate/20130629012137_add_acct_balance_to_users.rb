class AddAcctBalanceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_balance_cents, :integer, default: 0
  end
end
