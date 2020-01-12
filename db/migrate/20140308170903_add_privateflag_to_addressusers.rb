class AddPrivateflagToAddressusers < ActiveRecord::Migration
  def change
    add_column :addressusers, :private_flag, :boolean, default: false
  end
end
