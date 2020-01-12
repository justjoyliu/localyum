class AddStripeRecipientToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recipient_id, :string
  end
end
