class CreateSignups < ActiveRecord::Migration
  def change
    create_table :signups do |t|
      t.integer :hostevent_id
      t.integer :user_id
      t.boolean :confirmation_host, default: false
      t.boolean :confirmation_guest, default: false
      t.string :confirmation_status
      t.string :payment_status, default: 'Pending'
      t.decimal :payment_amt, :precision => 6, :scale => 2

      t.timestamps
    end

    add_index :signups, :hostevent_id
    add_index :signups, :user_id
    add_index :signups, [:hostevent_id, :user_id], unique: true
  end
end
