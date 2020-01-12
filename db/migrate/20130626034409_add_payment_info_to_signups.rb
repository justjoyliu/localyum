class AddPaymentInfoToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :charge_id, :string
    add_column :signups, :card_id, :string
    add_column :signups, :pay_portal_fee_cents, :integer
    add_column :signups, :card_last_4, :integer
    add_column :signups, :card_mth, :integer
    add_column :signups, :card_yr, :integer
    add_column :signups, :pay_failure_msg, :string
  end
end
