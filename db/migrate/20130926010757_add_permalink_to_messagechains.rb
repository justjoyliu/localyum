class AddPermalinkToMessagechains < ActiveRecord::Migration
  def change
    add_column :messagechains, :permalink, :string
    add_index :messagechains, :permalink, unique: true
  end
end
