class AddGuestCountToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :guest_count, :integer, default: 1
  end
end
