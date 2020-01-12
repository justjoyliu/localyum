class AddGmapsToAddressusers < ActiveRecord::Migration
  def change
    add_column :addressusers, :gmaps, :boolean
  end
end
