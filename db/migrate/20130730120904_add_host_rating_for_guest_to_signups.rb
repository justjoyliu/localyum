class AddHostRatingForGuestToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :host_rating_for_guest, :integer
  end
end
