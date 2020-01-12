class EventactivitiesHostevents < ActiveRecord::Migration
  def change
    create_table :eventactivities_hostevents, :id => false do |t|
      t.integer :hostevent_id, :null => false
      t.integer :eventactivity_id, :null => false
      #t.references :hostevent, :null => false
      #t.references :eventactivity, :null => false
    end

    add_index(:eventactivities_hostevents, [:hostevent_id, :eventactivity_id], 
    	:unique => true, :name => 'eventactivities_hostevents_id')
  end
end
