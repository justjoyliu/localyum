class AddUserIdToMenuitems < ActiveRecord::Migration
  def change
    add_column :menuitems, :user_id, :integer
  end
end
