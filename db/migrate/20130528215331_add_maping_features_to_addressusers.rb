class AddMapingFeaturesToAddressusers < ActiveRecord::Migration
  def change
    add_column :addressusers, :latitude, :float
    add_column :addressusers, :longitude, :float
    add_column :addressusers, :nickname, :string
    add_column :addressusers, :neighborhood, :string
  end
end
