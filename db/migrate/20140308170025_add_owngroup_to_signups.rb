class AddOwngroupToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :own_group_flag, :boolean, default: false
  end
end
