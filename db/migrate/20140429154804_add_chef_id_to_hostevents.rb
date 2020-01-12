class AddChefIdToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :chef_id, :integer
  end
end
