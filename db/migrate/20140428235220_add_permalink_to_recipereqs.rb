class AddPermalinkToRecipereqs < ActiveRecord::Migration
  def change
    add_column :recipereqs, :permalink, :string
    add_index :recipereqs, :permalink, unique: true
  end
end
