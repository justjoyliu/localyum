class AddStripePayoutToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :transfer_id, :string
    add_column :hostevents, :payout_method, :string, default: "Check"
    add_column :hostevents, :address_to_send_payout_id, :integer
    add_column :hostevents, :payout_status, :string
    add_column :hostevents, :payout_date, :date
  end
end
