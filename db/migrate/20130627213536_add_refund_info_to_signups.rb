class AddRefundInfoToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :refund_amt_cent, :integer
  end
end
