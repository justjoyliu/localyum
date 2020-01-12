class AddRatingsToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :taste_rating, :integer
    add_column :signups, :experience_rating, :integer
  end
end
