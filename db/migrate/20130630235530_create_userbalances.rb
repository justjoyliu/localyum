class CreateUserbalances < ActiveRecord::Migration
  def change
    create_table :userbalances do |t|
      t.string :transfer_id
      t.integer :amount
      t.string :status
      t.integer :user_id
      t.integer :stripe_fee

      t.timestamps
    end
  end
end
