class AddRequestEventToRecipereqs < ActiveRecord::Migration
  def change
    add_column :recipereqs, :as_host_flag, :boolean, default: false
    add_column :recipereqs, :req_date, :string
    add_column :recipereqs, :req_detail, :text
    add_column :recipereqs, :est_guests, :string
    add_column :recipereqs, :price_range, :string
    add_column :recipereqs, :req_addressuser_id, :integer
    add_column :recipereqs, :req_status, :integer, default: 0
    add_column :recipereqs, :hostevent_id, :integer
  end
end
