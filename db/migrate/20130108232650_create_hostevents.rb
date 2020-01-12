class CreateHostevents < ActiveRecord::Migration
  def change
    create_table :hostevents do |t|
      t.date :startdate
      t.datetime :mealstarttime
      t.decimal :price, :precision => 6, :scale => 2
      t.boolean :guestallowforprep, default: false
      t.datetime :timestartprep
      #t.integer :minguests, default: 1
      t.integer :maxguests #, default: 9999
      t.text :discussiontopics
      t.string :bestwaytocontact
      t.text :extracomments
      t.text :requestsforguests
      t.integer :mustbookhoursinadvance #, default:0
      t.string :eventstatus, default: 'Setup'
      t.boolean :confirmability, default: true
      t.integer :user_id
      t.integer :addressuser_id
      t.integer :eventcategory_id
      t.integer :charitypolicy_id
      t.integer :cancellationpolicy_id, default: 1
      #t.integer :eventactivity_id

      t.timestamps
    end

    add_index :hostevents, [:user_id, :startdate, :price]
  end
end
