class AddFbidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fbid, :integer
  end
end
