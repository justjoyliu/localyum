class CreateAddressusers < ActiveRecord::Migration
  def change
    create_table :addressusers do |t|
      t.string :line1
      t.string :city
      t.string :state
      t.string :zip5
      t.string :metroarea
      t.integer :user_id

      t.timestamps
    end

    add_index :addressusers, [:state, :zip5, :metroarea]
  end
end
