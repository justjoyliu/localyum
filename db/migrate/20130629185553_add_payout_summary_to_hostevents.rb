class AddPayoutSummaryToHostevents < ActiveRecord::Migration
  def change
    add_column :hostevents, :host_net_earnings_cents, :integer, default: 0
    add_column :hostevents, :host_charity_cents, :integer
    add_column :hostevents, :ly_charity_cents, :integer
    add_column :hostevents, :ly_net_host_fee, :integer
    add_column :hostevents, :payout_non_ach_info, :string
  end
end
