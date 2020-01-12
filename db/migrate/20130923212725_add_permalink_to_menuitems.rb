class AddPermalinkToMenuitems < ActiveRecord::Migration
  def change
    add_column :menuitems, :permalink, :string
    add_index :menuitems, :permalink, unique: true
  end
end
