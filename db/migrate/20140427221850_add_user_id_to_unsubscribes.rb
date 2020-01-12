class AddUserIdToUnsubscribes < ActiveRecord::Migration
  def change
    add_column :unsubscribes, :user_id, :integer
  end
end
