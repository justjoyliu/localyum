class AddUserTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :yummer_flag, :boolean, default: true
    add_column :users, :host_flag, :boolean, default: true
    add_column :users, :chef_flag, :boolean, default: true
  end
end
