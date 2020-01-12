class AddPermalinkToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :permalink, :string
    add_index :hostevents, :permalink, unique: true
  end
end
