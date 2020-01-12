class CreateCancellationpolicies < ActiveRecord::Migration
  def change
    create_table :cancellationpolicies do |t|
      t.integer :hrs_before_1
      t.integer :refund_percent_1
      t.integer :hrs_before_2
      t.integer :refund_percent_2
      t.string :cancellation_description

      t.timestamps
    end
    add_index :cancellationpolicies, [:hrs_before_1, :hrs_before_2]
  end
end
