class CreateMessagechains < ActiveRecord::Migration
  def change
    create_table :messagechains do |t|
      t.integer :hostevent_id
      t.string :title

      t.timestamps
    end
  end
end
