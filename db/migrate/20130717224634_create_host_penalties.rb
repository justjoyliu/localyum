class CreateHostPenalties < ActiveRecord::Migration
  def change
    create_table :host_penalties do |t|
      t.integer :hostevent_id
      t.integer :user_id
      t.integer :number_guests
      t.integer :amt_refunded_cents
      t.integer :penalty_amount_cents

      t.timestamps
    end
  end
end
