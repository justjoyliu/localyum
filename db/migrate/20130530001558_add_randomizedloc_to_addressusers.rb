class AddRandomizedlocToAddressusers < ActiveRecord::Migration
  def change
    add_column :addressusers, :lat_rand, :float
    add_column :addressusers, :lng_rand, :float
  end
end

