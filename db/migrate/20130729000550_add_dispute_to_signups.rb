class AddDisputeToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :dispute_flag, :boolean, default: false
  end
end
