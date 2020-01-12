class CreateEventphotos < ActiveRecord::Migration
  def change
    create_table :eventphotos do |t|
      #t.integer :user_id
      t.integer :hostevent_id
      t.string :photodescription
      t.boolean :onlyattendeeview, default: false

      t.attachment :eventpic
      t.timestamps
    end
  end

end
