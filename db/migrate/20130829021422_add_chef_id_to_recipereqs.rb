class AddChefIdToRecipereqs < ActiveRecord::Migration
  def change
  	add_column :recipereqs, :chef_id, :integer
  end
end
