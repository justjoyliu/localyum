class AddBookableToAddressusers < ActiveRecord::Migration
  def change
  	add_column :addressusers, :allow_booking_flag, :boolean, default: true
  end
end