class CreateUnsubscribes < ActiveRecord::Migration
  def change
    create_table :unsubscribes do |t|
      t.string :email
      t.string :status
      t.timestamps
    end

    add_index :unsubscribes, [:email]
  end
end
