class CreateEventactivities < ActiveRecord::Migration
  def change
    create_table :eventactivities do |t|
      t.string :activity
      #t.integer :hostevent_id

      t.timestamps
    end
  end
end
