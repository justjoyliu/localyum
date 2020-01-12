class ChangePaymentAmtInSignups < ActiveRecord::Migration
  def change
    change_column :signups, :payment_amt, :decimal, :precision => 12, :scale => 2
  end
end
