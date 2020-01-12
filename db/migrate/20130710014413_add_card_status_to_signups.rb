class AddCardStatusToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :card_status, :string, default: "ok"
  end
end
