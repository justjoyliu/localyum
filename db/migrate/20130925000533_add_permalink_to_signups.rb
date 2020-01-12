class AddPermalinkToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :permalink, :string
    add_index :signups, :permalink, unique: true
  end
end
