class HosteventsMenuitems < ActiveRecord::Migration
  def change
    create_table :hostevents_menuitems, :id => false do |t|
      t.integer :hostevent_id, :null => false
      t.integer :menuitem_id, :null => false
    end

    add_index(:hostevents_menuitems, [:hostevent_id, :menuitem_id], 
    	:unique => true, :name => 'hostevents_menuitems_id')
  end
end